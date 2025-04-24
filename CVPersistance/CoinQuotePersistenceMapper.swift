//  CoinQuotePersistenceMapper.swift
//  CoinVista
//
//  Created by lla.

import CVDomain
import CoreData

public enum CoinQuotePersistenceMapper {
    public static func map(entity: CoinQuoteEntity) -> CoinQuote? {
        guard let symbol = entity.symbol else { return nil }
        return CoinQuote(
            symbol: symbol,
            price: entity.price?.decimalValue ?? 0,
            priceChangePercent: entity.priceChangePercent?.decimalValue ?? 0
        )
    }

    public static func map(domain: CoinQuote, into context: NSManagedObjectContext) -> CoinQuoteEntity {
        let request: NSFetchRequest<CoinQuoteEntity> = CoinQuoteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "symbol == %@", domain.symbol)
        request.fetchLimit = 1

        let entity = (try? context.fetch(request).first) ?? CoinQuoteEntity(context: context)
        entity.symbol = domain.symbol
        entity.price = NSDecimalNumber(decimal: domain.price)
        entity.priceChangePercent = NSDecimalNumber(decimal: domain.priceChangePercent)
        entity.timestamp = Date()
        return entity
    }
}
