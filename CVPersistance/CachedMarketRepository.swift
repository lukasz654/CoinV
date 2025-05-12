//  CachedMarketRepository.swift
//  CoinVista
//
//  Created by lla.

import CoreData
import CVDomain
import Foundation
import Utilities

public final class CachedMarketRepository: MarketRepository {

    private let logger: CVLogger

    private let viewContext: NSManagedObjectContext
    private let backgroundContext: NSManagedObjectContext
    private let remote: MarketRepository
    private let calendar: Calendar
    private let freshnessThreshold: TimeInterval = 3600 // 1 hour

    public init(viewContext: NSManagedObjectContext,
                backgroundContext: NSManagedObjectContext,
                remote: MarketRepository,
                calendar: Calendar = .current,
                logger: CVLogger) {
        self.viewContext = viewContext
        self.backgroundContext = backgroundContext
        self.remote = remote
        self.calendar = calendar
        self.logger = logger
    }

    public func fetchCoins() async throws -> [Coin] {
        if let lastFetch = try? fetchLastFetchDate(type: "exchangeInfo"), isFresh(date: lastFetch) {
            logger.info("Using cached exchange info.")
            return fetchFromCache()
        } else {
            logger.info("Fetching fresh exchange info from remote.")
            let coins = try await remote.fetchCoins()
            try await persist(coins: coins)
            try saveLastFetchDate(type: "exchangeInfo")
            return coins
        }
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

        let result = (try? viewContext.fetch(request)) ?? []
        logger.info("Fetched \(result.count) coins from cache.")
        return CoinPersistenceMapper.map(entities: result)
    }

    private func persist(coins: [Coin]) async throws {
        try await backgroundContext.perform { [weak self] in
            guard let self else {
                return
            }
            for coin in coins {
                _ = CoinPersistenceMapper.map(domain: coin, into: backgroundContext)
            }
            try backgroundContext.save()
            logger.info("Persisted \(coins.count) coins to cache.")
        }
    }
    
    public func fetchQuotes() async throws -> [CoinQuote] {
        if let lastFetch = try? fetchLastFetchDate(type: "quotes"), isFresh(date: lastFetch) {
            logger.info("Using cached quotes.")
            return fetchQuotesFromCache()
        } else {
            logger.info("Fetching fresh quotes from remote.")
            let quotes = try await remote.fetchQuotes()
            try await persist(quotes: quotes)
            try saveLastFetchDate(type: "quotes")
            return quotes
        }
    }

    private func fetchQuotesFromCache() -> [CoinQuote] {
        let request = CoinQuoteEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "symbol", ascending: true)]

        let result = (try? viewContext.fetch(request)) ?? []
        return result.compactMap { CoinQuotePersistenceMapper.map(entity: $0) }
    }

    private func persist(quotes: [CoinQuote]) async throws {
        try await backgroundContext.perform { [weak self] in
            guard let self else {
                return
            }
            for quote in quotes {
                _ = CoinQuotePersistenceMapper.map(domain: quote, into: backgroundContext)
            }
            try backgroundContext.save()
            logger.info("Persisted \(quotes.count) quotes to cache.")
        }
    }

    private func fetchLastFetchDate(type: String) throws -> Date? {
        let request = LastFetchInfoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "type == %@", type)
        request.fetchLimit = 1

        let result = try viewContext.fetch(request).first?.timestamp
        logger.info("Last fetch date for \(type): \(result?.description ?? "nil")")
        return result
    }

    private func saveLastFetchDate(type: String) throws {
        try backgroundContext.performAndWait {
            let request = LastFetchInfoEntity.fetchRequest()
            request.predicate = NSPredicate(format: "type == %@", type)

            let existing = try backgroundContext.fetch(request).first ?? LastFetchInfoEntity(context: backgroundContext)
            existing.type = type
            existing.timestamp = Date()

            try backgroundContext.save()
            logger.info("Saved fetch timestamp for \(type).")
        }
    }

    public func toggleWatchlist(for symbol: String) async throws {
        try await backgroundContext.perform { [weak self] in
            guard let self else {
                return
            }
            let request: NSFetchRequest<CoinEntity> = CoinEntity.fetchRequest()
            request.predicate = NSPredicate(format: "symbol == %@", symbol)
            request.fetchLimit = 1

            guard let entity = try backgroundContext.fetch(request).first else {
                logger.warning("Attempted to toggle watchlist for missing coin: \(symbol)")
                return
            }

            entity.isWatchlisted.toggle()
            try backgroundContext.save()
            logger.info("Toggled watchlist for symbol: \(symbol) to \(entity.isWatchlisted)")
        }
    }
}

extension CachedMarketRepository: WatchlistWritable {}
