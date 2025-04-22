//  CoinQuoteDTO.swift
//  CoinVista
//
//  Created by lla.

import Foundation

public struct CoinQuoteDTO: Equatable, Hashable {
    public let symbol: String
    public let price: Decimal
    public let priceChangePercent: Decimal

    public init?(symbol: String, lastPrice: String, priceChangePercent: String) {
        guard let price = Decimal(string: lastPrice),
              let change = Decimal(string: priceChangePercent) else {
            return nil
        }
        self.symbol = symbol
        self.price = price
        self.priceChangePercent = change
    }
}
