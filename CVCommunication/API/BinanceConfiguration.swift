//  BinanceAPI.swift
//  CoinVista
//
//  Created by lla.

import Foundation

public struct BinanceConfiguration {
    public let baseURL: URL

    public init?(baseURLString: String = "https://api.binance.com") {
        guard let url = URL(string: baseURLString) else {
            return nil
        }
        self.baseURL = url
    }
}
