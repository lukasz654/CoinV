//  BinanceAPI.swift
//  CoinVista
//
//  Created by lla.

import Foundation

public struct BinanceConfiguration {
    public let baseURL: URL

    public init(baseURLString: String = "https://api.binance.com") {
        guard let url = URL(string: baseURLString) else {
            preconditionFailure("Bad URL: \(baseURLString)")
        }
        self.baseURL = url
    }
}
