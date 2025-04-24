//  DefaultFetchMarketsUseCase.swift
//  CoinVista
//
//  Created by lla.

import Foundation

public final class DefaultFetchMarketsUseCase: FetchMarketsUseCase {
    private let repository: MarketRepository

    public init(repository: MarketRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [(coin: Coin, quote: CoinQuote?)] {
        let coins = try await repository.fetchCoins()
        let quotes = try await repository.fetchQuotes()

        let quoteMap = Dictionary(uniqueKeysWithValues: quotes.map { ($0.symbol, $0) })

        return coins.map { coin in
            (coin, quoteMap[coin.symbol])
        }
    }
}
