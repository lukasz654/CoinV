//  MarketRepository.swift
//  CoinVista
//
//  Created by lla.

import Foundation

public protocol MarketRepository {
    func fetchCoins() async throws -> [Coin]
    func fetchQuotes() async throws -> [CoinQuote]
}
