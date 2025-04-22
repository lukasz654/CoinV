//  BinanceMarketService.swift
//  CoinVista
//
//  Created by lla.

import Foundation

public final class BinanceMarketService: MarketService {
    private let session: URLSession
    private let configuration: BinanceConfiguration

    public init(session: URLSession = .shared, configuration: BinanceConfiguration = BinanceConfiguration()) {
        self.session = session
        self.configuration = configuration
    }

    public func fetchExchangeInfo() async throws -> [CoinDTO] {
        let request = Endpoint.exchangeInfo.makeRequest(using: configuration)
        let (data, _) = try await session.data(for: request)
        let response = try JSONDecoder().decode(ExchangeInfoResponse.self, from: data)

        return response.symbols
            .map { CoinDTO(symbol: $0.symbol, baseAsset: $0.baseAsset, quoteAsset: $0.quoteAsset) }
    }

    public func fetchTickers() async throws -> [CoinQuoteDTO] {
        let request = Endpoint.ticker24h.makeRequest(using: configuration)
        let (data, _) = try await session.data(for: request)
        let tickers = try JSONDecoder().decode([Ticker24hResponse].self, from: data)

        return tickers.compactMap {
            CoinQuoteDTO(symbol: $0.symbol, lastPrice: $0.lastPrice, priceChangePercent: $0.priceChangePercent)
        }
    }
}

