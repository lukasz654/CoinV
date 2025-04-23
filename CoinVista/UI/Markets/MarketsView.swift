//  MarketsView.swift
//  CoinVista
//
//  Created by lla.

import CVDomain
import SwiftUI

struct MarketsView: View {
    @StateObject var viewModel: MarketsViewModel

    var body: some View {
        NavigationStack {
            content
            .navigationTitle("Markets")
        }
        .task {
            await viewModel.load()
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
        }
        .searchable(text: $viewModel.searchText)
        .listStyle(.plain)
    }
}

#if DEBUG
import CVDomain

final class MockFetchMarketsUseCase: FetchMarketsUseCase {
    func execute() async throws -> [(coin: Coin, quote: CoinQuote?)] {
        [
            (Coin(symbol: "BTCUSDT", baseAsset: "BTC", quoteAsset: "USDT"),
             CoinQuote(symbol: "BTCUSDT", price: 27342.12, priceChangePercent: -1.2)),
            (Coin(symbol: "ETHUSDT", baseAsset: "ETH", quoteAsset: "USDT"),
             CoinQuote(symbol: "ETHUSDT", price: 1623.55, priceChangePercent: 2.45))
        ]
    }
}

#Preview("MarketsView") {
    let mockUseCase = MockFetchMarketsUseCase()
    let vm = MarketsViewModel(useCase: mockUseCase)
    return MarketsView(viewModel: vm)
}
#endif
