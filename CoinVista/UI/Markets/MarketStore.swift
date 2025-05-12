//  MarketStore.swift
//  CoinVista
//
//  Created by lla.

import CVDomain
import Combine
import Foundation
import Utilities

enum MarketLoadState: Equatable {
    case idle
    case loading
    case success
    case failure
    case offlineWithCache
}

@MainActor
final class MarketStore: ObservableObject {
    @Published var searchText: String = ""

    @Published private(set) var items: [MarketRowViewModel] = []
    @Published private(set) var loadState: MarketLoadState = .idle
    @Published private(set) var error: Error?
    @Published private(set) var lastUpdate: Date?

    private let fetchUseCase: FetchMarketsUseCase
    private let toggleWatchlistUseCase: ToggleWatchlistUseCase
    private let logger: CVLogger

    private var allItems: [MarketRowViewModel] = []
    private var hasLoaded = false
    private var cancellables = Set<AnyCancellable>()

    init(fetchUseCase: FetchMarketsUseCase,
         toggleWatchlistUseCase: ToggleWatchlistUseCase,
         logger: CVLogger) {
        self.fetchUseCase = fetchUseCase
        self.toggleWatchlistUseCase = toggleWatchlistUseCase
        self.logger = logger
        bind()
    }

    func loadIfNeeded() async {
        guard !hasLoaded else { return }
        await load()
    }

    func retry() async {
        hasLoaded = false
        await load()
    }

    func toggleWatchlist(for symbol: String) async {
        do {
            try await toggleWatchlistUseCase.execute(symbol: symbol)
            if let index = allItems.firstIndex(where: { $0.id == symbol }) {
                let item = allItems[index]
                allItems[index] = MarketRowViewModel(
                    coin: Coin(
                        symbol: item.coin.symbol,
                        baseAsset: item.coin.baseAsset,
                        quoteAsset: item.coin.quoteAsset,
                        isWatchlisted: !item.coin.isWatchlisted
                    ),
                    quote: item.quote
                )
                applyFilter()
            }
        } catch {
            logger.error("Toggle failed: \(error)")
        }
    }

    private func load() async {
        loadState = .loading
        do {
            let result = try await fetchUseCase.execute()
            allItems = result.map { MarketRowViewModel(coin: $0.0, quote: $0.1) }
            applyFilter()
            lastUpdate = Date()
            loadState = .success
            error = nil
        } catch {
            logger.error("Failed to load: \(error)")
            self.error = error
            self.loadState = .failure
        }
        hasLoaded = true
    }

    private func bind() {
        $searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.applyFilter()
            }
            .store(in: &cancellables)
    }

    private func applyFilter() {
        guard !searchText.isEmpty else {
            items = allItems
            return
        }
        items = allItems.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
    }
}
