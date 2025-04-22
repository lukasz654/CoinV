//  Ticker24hResponse.swift
//  CoinVista
//
//  Created by lla.

public struct Ticker24hResponse: Decodable {
    public let symbol: String
    public let lastPrice: String
    public let priceChangePercent: String
}
