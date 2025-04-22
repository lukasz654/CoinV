//  CoinQuote.swift
//  CoinVista
//
//  Created by lla.

import Foundation

public struct CoinQuote: Equatable, Hashable {
    public let symbol: String
    public let price: Decimal
    public let priceChangePercent: Decimal

    public init(symbol: String, price: Decimal, priceChangePercent: Decimal) {
        self.symbol = symbol
        self.price = price
        self.priceChangePercent = priceChangePercent
    }
}
