//  WatchlistWritable.swift
//  CoinVista
//
//  Created by lla.

public protocol WatchlistWritable {
    func toggleWatchlist(for symbol: String) throws
}
