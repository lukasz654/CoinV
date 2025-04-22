//  MarketService.swift
//  CoinVista
//
//  Created by lla.

public protocol MarketService {
    func fetchExchangeInfo() async throws -> [CoinDTO]
    func fetchTickers() async throws -> [CoinQuoteDTO]
}
