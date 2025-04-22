//  CoinDTO.swift
//  CoinVista
//
//  Created by lla.

public struct CoinDTO: Equatable, Hashable {
    public let symbol: String
    public let baseAsset: String
    public let quoteAsset: String

    public init(symbol: String, baseAsset: String, quoteAsset: String) {
        self.symbol = symbol
        self.baseAsset = baseAsset
        self.quoteAsset = quoteAsset
    }
}
