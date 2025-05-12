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
        async let coinsTask = repository.fetchCoins()
        async let quotesTask = repository.fetchQuotes()
        
        let (coins, quotes) = try await (coinsTask, quotesTask)
        
        let quoteMap = Dictionary(uniqueKeysWithValues: quotes.map { ($0.symbol, $0) })
        
        return coins.map { coin in
            (coin, quoteMap[coin.symbol])
        }
    }
}
