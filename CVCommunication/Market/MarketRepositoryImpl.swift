//  MarketRepositoryImpl.swift
//  CoinVista
//
//  Created by lla.

import CVDomain

public final class MarketRepositoryImpl: MarketRepository {
    private let service: MarketService

    public init(service: MarketService) {
        self.service = service
    }

    public func fetchCoins() async throws -> [Coin] {
        let dtos = try await service.fetchExchangeInfo()
        return CoinMapper.map(dto: dtos)
    }

    public func fetchQuotes() async throws -> [CoinQuote] {
        let dtos = try await service.fetchTickers()
        return CoinMapper.map(dto: dtos)
    }
}

