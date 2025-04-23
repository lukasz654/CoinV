//  Endpoint.swift
//  CoinVista
//
//  Created by lla.

import Foundation

public enum Endpoint: String {
    case exchangeInfo = "/api/v3/exchangeInfo"
    case ticker24h = "/api/v3/ticker/24hr"

    public func makeRequest(using configuration: BinanceConfiguration) throws -> URLRequest {
        guard let url = URL(string: rawValue, relativeTo: configuration.baseURL) else {
            throw EndpointError.invalidURL(rawValue)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
}

public enum EndpointError: Error, Equatable {
    case invalidURL(String)
}
