//  BinanceMarketService.swift
//  CoinVista
//
//  Created by lla.

import Foundation

public enum BinanceServiceError: Error {
    case invalidConfiguration
    case invalidURL
    case requestFailed(Error)
    case invalidResponse(code: Int, message: String?)
    case decodingFailed(Error)
}

private struct BinanceErrorMessage: Decodable {
    let code: Int
    let msg: String
}

public final class BinanceMarketService: MarketService {
    private let session: URLSession
    private let configuration: BinanceConfiguration

    public init(session: URLSession = .shared, configuration: BinanceConfiguration? = BinanceConfiguration()) throws {
        guard let configuration = configuration else {
            throw BinanceServiceError.invalidConfiguration
        }
        self.session = session
        self.configuration = configuration
    }

    public func fetchExchangeInfo() async throws -> [CoinDTO] {
        let request: URLRequest
        do {
            request = try Endpoint.exchangeInfo.makeRequest(using: configuration)
        } catch {
            throw BinanceServiceError.invalidURL
        }

        do {
            let (data, response) = try await session.data(for: request)
            try validate(response: response, data: data)
            let decoded = try JSONDecoder().decode(ExchangeInfoResponse.self, from: data)
            return decoded.symbols.map {
                CoinDTO(symbol: $0.symbol, baseAsset: $0.baseAsset, quoteAsset: $0.quoteAsset)
            }
        } catch let error as BinanceServiceError {
            throw error
        } catch let decodingError as DecodingError {
            throw BinanceServiceError.decodingFailed(decodingError)
        } catch {
            throw BinanceServiceError.requestFailed(error)
        }
    }

    public func fetchTickers() async throws -> [CoinQuoteDTO] {
        let request: URLRequest
        do {
            request = try Endpoint.ticker24h.makeRequest(using: configuration)
        } catch {
            throw BinanceServiceError.invalidURL
        }

        do {
            let (data, response) = try await session.data(for: request)
            try validate(response: response, data: data)
            let tickers = try JSONDecoder().decode([Ticker24hResponse].self, from: data)
            return tickers.compactMap {
                CoinQuoteDTO(symbol: $0.symbol, lastPrice: $0.lastPrice, priceChangePercent: $0.priceChangePercent)
            }
        } catch let error as BinanceServiceError {
            throw error
        } catch let decodingError as DecodingError {
            throw BinanceServiceError.decodingFailed(decodingError)
        } catch {
            throw BinanceServiceError.requestFailed(error)
        }
    }

    private func validate(response: URLResponse?, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BinanceServiceError.invalidResponse(code: -1, message: "No response")
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let message = try? JSONDecoder().decode(BinanceErrorMessage.self, from: data)
            throw BinanceServiceError.invalidResponse(code: httpResponse.statusCode, message: message?.msg)
        }
    }
}
