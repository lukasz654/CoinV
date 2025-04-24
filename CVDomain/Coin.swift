//  Coin.swift
//  CoinVista
//
//  Created by lla.

public struct Coin: Equatable, Hashable {
    public let symbol: String
    public let baseAsset: String
    public let quoteAsset: String
    public let isWatchlisted: Bool

    public init(symbol: String, baseAsset: String, quoteAsset: String, isWatchlisted: Bool = false) {
        self.symbol = symbol
        self.baseAsset = baseAsset
        self.quoteAsset = quoteAsset
        self.isWatchlisted = isWatchlisted
    }
}
