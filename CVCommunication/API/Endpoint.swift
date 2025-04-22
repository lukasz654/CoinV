//  Endpoint.swift
//  CoinVista
//
//  Created by lla.

import Foundation

public enum Endpoint {
    case exchangeInfo
    case ticker24h

    public func makeRequest(using configuration: BinanceConfiguration) -> URLRequest {
        let url: URL?
        switch self {
        case .exchangeInfo:
            url = URL(string: "/api/v3/exchangeInfo", relativeTo: configuration.baseURL)
        case .ticker24h:
            url = URL(string: "/api/v3/ticker/24hr", relativeTo: configuration.baseURL)
        }

        let safeURL = url ?? configuration.baseURL
        var request = URLRequest(url: safeURL)
        request.httpMethod = "GET"
        return request
    }
}
