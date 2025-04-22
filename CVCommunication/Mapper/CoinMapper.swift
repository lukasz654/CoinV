//  CoinMapper.swift
//  CoinVista
//
//  Created by lla.

import CVDomain
import Foundation

public enum CoinMapper {
    public static func map(dto: [CoinDTO]) -> [Coin] {
        dto.map { Coin(symbol: $0.symbol, baseAsset: $0.baseAsset, quoteAsset: $0.quoteAsset) }
    }

    public static func map(dto: [CoinQuoteDTO]) -> [CoinQuote] {
        dto.map { CoinQuote(symbol: $0.symbol, price: $0.price, priceChangePercent: $0.priceChangePercent) }
    }
}
