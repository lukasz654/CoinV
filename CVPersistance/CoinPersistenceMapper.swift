//  CoinPersistenceMapper.swift
//  CoinVista
//
//  Created by lla.

import Foundation
import CVDomain
import CoreData

public enum CoinPersistenceMapper {
    public static func map(entity: CoinEntity) -> Coin? {
        guard let symbol = entity.symbol,
              let baseAsset = entity.baseAsset,
              let quoteAsset = entity.quoteAsset else {
            return nil
        }

        return Coin(symbol: symbol, baseAsset: baseAsset, quoteAsset: quoteAsset)
    }

    public static func map(domain: Coin, into context: NSManagedObjectContext) -> CoinEntity {
        let entity = CoinEntity(context: context)
        entity.symbol = domain.symbol
        entity.baseAsset = domain.baseAsset
        entity.quoteAsset = domain.quoteAsset
        return entity
    }

    public static func map(entities: [CoinEntity]) -> [Coin] {
        entities.compactMap { map(entity: $0) }
    }
}
