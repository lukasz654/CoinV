//  BinanceAPI.swift
//  CoinVista
//
//  Created by lla.

import Foundation

public struct BinanceConfiguration {
    public let baseURL: URL

    public init(baseURL: URL = URL(string: "https://api.binance.com")!) {
        self.baseURL = baseURL
    }
}
