//  CachedFetcher.swift
//  CoinVista
//
//  Created by lla.

import CoreData
import CVDomain
import Utilities

public final class CachedFetcher<Domain, Entity: NSManagedObject> {
    private let fetchType: FetchType
    private let remoteFetch: () async throws -> [Domain]
    private let fetchFromCache: () -> [Domain]
    private let persist: ([Domain]) async throws -> Void
    private let logger: CVLogger
    private let backgroundContext: NSManagedObjectContext
    private let viewContext: NSManagedObjectContext
    private let calendar: Calendar
    private let freshnessThreshold: TimeInterval
    
    public init(
        fetchType: FetchType,
        remoteFetch: @escaping () async throws -> [Domain],
        fetchFromCache: @escaping () -> [Domain],
        persist: @escaping ([Domain]) async throws -> Void,
        backgroundContext: NSManagedObjectContext,
        viewContext: NSManagedObjectContext,
        calendar: Calendar,
        freshnessThreshold: TimeInterval = 3600,
        logger: CVLogger
    ) {
        self.fetchType = fetchType
        self.remoteFetch = remoteFetch
        self.fetchFromCache = fetchFromCache
        self.persist = persist
        self.backgroundContext = backgroundContext
        self.viewContext = viewContext
        self.calendar = calendar
        self.freshnessThreshold = freshnessThreshold
        self.logger = logger
    }
    
    public func fetch() async throws -> [Domain] {
        if let last = try? fetchLastFetchDate(), isFresh(date: last) {
            logger.info("Using cached \(fetchType.rawValue).")
            return fetchFromCache()
        } else {
            logger.info("Fetching fresh \(fetchType.rawValue) from remote.")
            let items = try await remoteFetch()
            try await persist(items)
            try saveLastFetchDate()
            return items
        }
    }
    
    private func isFresh(date: Date) -> Bool {
        guard let diff = calendar.dateComponents([.second], from: date, to: Date()).second else {
            return false
        }
        return diff < Int(freshnessThreshold)
    }
    
    private func fetchLastFetchDate() throws -> Date? {
        let request = LastFetchInfoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "type == %@", fetchType.rawValue)
        request.fetchLimit = 1
        
        let result = try viewContext.fetch(request).first?.timestamp
        logger.info("Last fetch date for \(fetchType.rawValue): \(result?.description ?? "nil")")
        return result
    }
    
    private func saveLastFetchDate() throws {
        try backgroundContext.performAndWait {
            let request = LastFetchInfoEntity.fetchRequest()
            request.predicate = NSPredicate(format: "type == %@", fetchType.rawValue)
            let existing = try backgroundContext.fetch(request).first ?? LastFetchInfoEntity(context: backgroundContext)
            existing.type = fetchType.rawValue
            existing.timestamp = Date()
            try backgroundContext.save()
            logger.info("Saved fetch timestamp for \(fetchType.rawValue).")
        }
    }
}
