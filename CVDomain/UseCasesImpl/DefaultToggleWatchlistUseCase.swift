//  DefaultToggleWatchlistUseCase.swift
//  CoinVista
//
//  Created by lla.

public final class DefaultToggleWatchlistUseCase: ToggleWatchlistUseCase {
    private let repository: WatchlistWritable

    public init(repository: WatchlistWritable) {
        self.repository = repository
    }

    public func execute(symbol: String) async throws {
        try await repository.toggleWatchlist(for: symbol)
    }
}
