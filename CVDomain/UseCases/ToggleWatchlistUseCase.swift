//  ToggleWatchlistUseCase.swift
//  CoinVista
//
//  Created by lla.

public protocol ToggleWatchlistUseCase {
    func execute(symbol: String) throws
}
