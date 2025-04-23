//  CachedMarketRepository.swift
//  CoinVista
//
//  Created by lla.

import CoreData
import CVDomain
import Foundation
import Utilities

public final class CachedMarketRepository: MarketRepository {

    private let logger = CVLog.shared

    private let context: NSManagedObjectContext
    private let remote: MarketRepository
    private let calendar: Calendar
    private let freshnessThreshold: TimeInterval = 3600 // 1 hour

    public init(context: NSManagedObjectContext = PersistenceController.shared.viewContext,
                remote: MarketRepository,
                calendar: Calendar = .current) {
        self.context = context
        self.remote = remote
        self.calendar = calendar
    }

    public func fetchCoins() async throws -> [Coin] {
        if let lastFetch = try? fetchLastFetchDate(type: "exchangeInfo"), isFresh(date: lastFetch) {
            logger.info("Using cached exchange info.")
            return fetchFromCache()
        } else {
            logger.info("Fetching fresh exchange info from remote.")
            let coins = try await remote.fetchCoins()
            try persist(coins: coins)
            try saveLastFetchDate(type: "exchangeInfo")
            return coins
        }
    }

    public func fetchQuotes() async throws -> [CoinQuote] {
        try await remote.fetchQuotes()
    }

    private func isFresh(date: Date) -> Bool {
        guard let diff = calendar.dateComponents([.second], from: date, to: Date()).second else {
            return false
        }
        return diff < Int(freshnessThreshold)
    }

    private func fetchFromCache() -> [Coin] {
        let request = CoinEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "symbol", ascending: true)]

        let result = (try? context.fetch(request)) ?? []
        logger.info("Fetched \(result.count) coins from cache.")
        return CoinPersistenceMapper.map(entities: result)
    }

    private func persist(coins: [Coin]) throws {
        try validateEntityExists(named: "CoinEntity")
        try deleteAllEntities(named: "CoinEntity")

        for coin in coins {
            _ = CoinPersistenceMapper.map(domain: coin, into: context)
        }

        do {
            try context.save()
            logger.info("Persisted \(coins.count) coins to cache.")
        } catch {
            logger.error("Failed to save context: \(error.localizedDescription)")
            throw PersistenceError.saveFailed(error)
        }
    }

    private func validateEntityExists(named name: String) throws {
        guard context.persistentStoreCoordinator?.managedObjectModel.entitiesByName[name] != nil else {
            let error = NSError(
                domain: "CVPersistence",
                code: 1001,
                userInfo: [NSLocalizedDescriptionKey: "\(name) not found in Core Data model"]
            )
            logger.error("CoreData error: \(error.localizedDescription)")
            throw error
        }
    }

    private func deleteAllEntities(named name: String) throws {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: name)
        let delete = NSBatchDeleteRequest(fetchRequest: request)
        try context.execute(delete)
    }

    private func fetchLastFetchDate(type: String) throws -> Date? {
        let request = LastFetchInfoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "type == %@", type)
        request.fetchLimit = 1

        let date = try context.fetch(request).first?.timestamp
        logger.info("Last fetch date for \(type): \(date?.description ?? "nil")")
        return date
    }

    private func saveLastFetchDate(type: String) throws {
        let request = LastFetchInfoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "type == %@", type)

        let existing = try context.fetch(request).first ?? LastFetchInfoEntity(context: context)
        existing.type = type
        existing.timestamp = Date()

        try context.save()
        logger.info("Saved fetch timestamp for \(type).")
    }
}
