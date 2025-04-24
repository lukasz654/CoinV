//  CoinPersistenceMapper.swift
//  CoinVista
//
//  Created by lla.

import Foundation
import CVDomain
import CoreData

public enum CoinPersistenceMapper {
    public static func map(entities: [CoinEntity]) -> [Coin] {
        entities.compactMap { entity in
            guard let symbol = entity.symbol, let base = entity.baseAsset, let quote = entity.quoteAsset else {
                return nil
            }

            return Coin(symbol: symbol, baseAsset: base, quoteAsset: quote, isWatchlisted: entity.isWatchlisted)
        }
    }

    public static func map(domain: Coin, into context: NSManagedObjectContext) -> CoinEntity {
        let request: NSFetchRequest<CoinEntity> = CoinEntity.fetchRequest()
        request.predicate = NSPredicate(format: "symbol == %@", domain.symbol)
        request.fetchLimit = 1

        let entity = (try? context.fetch(request).first) ?? CoinEntity(context: context)
        entity.symbol = domain.symbol
        entity.baseAsset = domain.baseAsset
        entity.quoteAsset = domain.quoteAsset
        entity.isWatchlisted = domain.isWatchlisted || entity.isWatchlisted

        return entity
    }
}
