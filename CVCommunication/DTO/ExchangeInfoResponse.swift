//  ExchangeInfoResponse.swift
//  CoinVista
//
//  Created by lla.

public struct ExchangeInfoResponse: Decodable {
    public struct Symbol: Decodable {
        public let symbol: String
        public let baseAsset: String
        public let quoteAsset: String
        public let status: String
        public let isSpotTradingAllowed: Bool
    }

    public let symbols: [Symbol]
}
