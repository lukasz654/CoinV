//  MarketsViewModel.swift
//  CoinVista
//
//  Created by lla.

import Combine
import CVCommunication
import CVDomain
import CVPersistance
import Foundation
import Utilities

@MainActor
final class MarketsViewModel: ObservableObject {
    @Published var searchText = ""
    @Published private(set) var items: [MarketRowViewModel] = []
    @Published private(set) var loadState: MarketLoadState = .idle
    @Published private(set) var error: Error?
    @Published private(set) var lastUpdate: Date?

    private let dataLoader: MarketDataLoader
    private let stateManager: MarketListStateManager

    init(dataLoader: MarketDataLoader, stateManager: MarketListStateManager) {
        self.dataLoader = dataLoader
        self.stateManager = stateManager
        setupBindings()
    }

    func loadIfNeeded() async {
        await dataLoader.loadIfNeeded()
    }

    func retry() async {
        await dataLoader.retry()
    }

    func toggleWatchlist(for symbol: String) async {
        await stateManager.toggleWatchlist(for: symbol)
    }

    private func setupBindings() {
        Publishers.CombineLatest($searchText, stateManager.$allItems)
            .receive(on: RunLoop.main)
            .map { searchText, allItems in
                guard !searchText.isEmpty else { return allItems }
                return allItems.filter { $0.name.lowercased().contains(searchText.lowercased()) }
            }
            .assign(to: &$items)
        dataLoader.$loadState
                .receive(on: RunLoop.main)
                .assign(to: &$loadState)

            dataLoader.$error
                .receive(on: RunLoop.main)
                .assign(to: &$error)

            dataLoader.$lastUpdate
                .receive(on: RunLoop.main)
                .assign(to: &$lastUpdate)
    }
}
