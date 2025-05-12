//  MarketsView.swift
//  CoinVista
//
//  Created by lla.

import CVDomain
import SwiftUI

struct MarketsView: View {
    @StateObject var viewModel: MarketStore

    var body: some View {
        NavigationStack {
            content
            .navigationTitle("Markets")
        }
        .task {
            await viewModel.loadIfNeeded()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.loadState {
        case .idle, .loading:
            ProgressView()

        case .success, .offlineWithCache:
            marketsList
                .overlay(alignment: .bottom) {
                    if viewModel.loadState == .offlineWithCache,
                       let lastUpdate = viewModel.lastUpdate {
                        Text("Offline – cached data from \(lastUpdate.formatted(.dateTime.hour().minute()))")
                            .font(.footnote)
                            .padding(6)
                            .background(.ultraThinMaterial)
                            .cornerRadius(8)
                            .padding()
                    }
                }

        case .failure:
            VStack(spacing: 16) {
                Text(viewModel.error?.localizedDescription ?? "An unknown error occurred")
                    .foregroundColor(.secondary)
                Button("Try again") {
                    Task { await viewModel.retry() }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }

    private var marketsList: some View {
        List(viewModel.items) { item in
            MarketRow(item: item)
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button {
                        Task {
                                await viewModel.toggleWatchlist(for: item.id)
                            }
                    } label: {
                        Label(item.isWatchlisted ? "Remove" : "Add", systemImage: item.isWatchlisted ? "star.slash" : "star")
                    }
                    .tint(item.isWatchlisted ? .red : .blue)
                }
        }
        .searchable(text: $viewModel.searchText)
        .listStyle(.plain)
    }
}

#if DEBUG
import CVDomain
import Utilities
import SwiftUI

final class MockFetchMarketsUseCase: FetchMarketsUseCase {
    func execute() async throws -> [(coin: Coin, quote: CoinQuote?)] {
        [
            (
                Coin(symbol: "BTCUSDT", baseAsset: "BTC", quoteAsset: "USDT", isWatchlisted: true),
                CoinQuote(symbol: "BTCUSDT", price: 27342.12, priceChangePercent: -1.2)
            ),
            (
                Coin(symbol: "ETHUSDT", baseAsset: "ETH", quoteAsset: "USDT", isWatchlisted: false),
                CoinQuote(symbol: "ETHUSDT", price: 1623.55, priceChangePercent: 2.45)
            )
        ]
    }
}

final class MockToggleWatchlistUseCase: ToggleWatchlistUseCase {
    func execute(symbol: String) async throws {}
}

final class MockLogger: CVLogger {
    func debug(_ message: String) {}
    func info(_ message: String) {}
    func warning(_ message: String) {}
    func error(_ message: String) {}
}

#Preview("MarketsView") {
    let logger = MockLogger()
    let fetch = MockFetchMarketsUseCase()
    let toggle = MockToggleWatchlistUseCase()

    let store = MarketStore(
        fetchUseCase: fetch,
        toggleWatchlistUseCase: toggle,
        logger: logger
    )

    return MarketsView(viewModel: store)
}
#endif
