//  FetchMarketsUseCase.swift
//  CoinVista
//
//  Created by lla.

import Foundation

public protocol FetchMarketsUseCase {
    func execute() async throws -> [(coin: Coin, quote: CoinQuote?)]
}
