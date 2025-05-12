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
    enum LoadState: Equatable {
        case idle
        case loading
        case success
        case failure
        case offlineWithCache
    }

    @Published private(set) var items: [MarketRowViewModel] = []
    @Published var searchText: String = ""
    @Published private(set) var loadState: LoadState = .idle
    @Published var lastUpdate: Date?
    @Published var error: BinanceServiceError?

    private let useCase: FetchMarketsUseCase
    private let toggleWatchlistUseCase: ToggleWatchlistUseCase
    private var allItems: [MarketRowViewModel] = []
    private var cancellables = Set<AnyCancellable>()
    private var hasLoaded = false
    private let logger: CVLogger

    init(useCase: FetchMarketsUseCase,
         toggleWatchlistUseCase: ToggleWatchlistUseCase,
         logger: CVLogger) {
        self.useCase = useCase
        self.toggleWatchlistUseCase = toggleWatchlistUseCase
        self.logger = logger
        setupBindings()
    }

    func loadIfNeeded() async {
        guard !hasLoaded else {
            return
        }
        await load()
    }

    func load() async {
        loadState = .loading
        defer {
            if items.isEmpty {
                loadState = .idle
            }
        }

        do {
            let result = try await useCase.execute()
            allItems = result.map { MarketRowViewModel(coin: $0.coin, quote: $0.quote) }
            applyFilter()
            lastUpdate = Date()
            loadState = .success
            error = nil
        } catch let BinanceServiceError.invalidResponse(code, message) {
            logger.error("Binance API error [\(code)]: \(message ?? "Unknown")")
            self.error = BinanceServiceError.invalidResponse(code: code, message: message)
            if !allItems.isEmpty {
                loadState = .offlineWithCache
            } else {
                loadState = .failure
            }
        } catch {
            logger.error("Unexpected error: \(error)")
            self.error = error as? BinanceServiceError ?? .requestFailed(error)
            if !allItems.isEmpty {
                loadState = .offlineWithCache
            } else {
                loadState = .failure
            }
        }
        hasLoaded = true
    }

    func retry() async {
        await load()
    }

    func toggleWatchlist(for symbol: String) {
        Task {
            do {
                try await toggleWatchlistUseCase.execute(symbol: symbol)
                logger.info("User toggled watchlist for \(symbol)")

                if let index = allItems.firstIndex(where: { $0.id == symbol }) {
                    let item = allItems[index]

                    let updatedCoin = Coin(
                        symbol: item.coin.symbol,
                        baseAsset: item.coin.baseAsset,
                        quoteAsset: item.coin.quoteAsset,
                        isWatchlisted: !item.coin.isWatchlisted
                    )

                    let updatedItem = MarketRowViewModel(
                        coin: updatedCoin,
                        quote: item.quote
                    )

                    allItems[index] = updatedItem
                    applyFilter()
                }
            } catch {
                logger.error("Failed to toggle watchlist for \(symbol): \(error)")
            }
        }
    }

    func applyFilter() {
        if searchText.isEmpty {
            items = allItems
        } else {
            let lowercased = searchText.lowercased()
            items = allItems.filter {
                $0.name.lowercased().contains(lowercased)
            }
        }
    }

    private func setupBindings() {
        $searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.applyFilter()
                self?.logger.info("Search filter applied: \(self?.searchText ?? "")")
            }
            .store(in: &cancellables)
    }
}
