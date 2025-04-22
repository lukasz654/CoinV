//  MarketsView.swift
//  CoinVista
//
//  Created by lla.

import SwiftUI

struct MarketsView: View {
    @StateObject var viewModel: MarketsViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if !viewModel.items.isEmpty {
                    List(viewModel.items) { item in
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.headline)
                            HStack {
                                Text(item.price)
                                Spacer()
                                Text(item.change)
                                    .foregroundColor(item.change.hasPrefix("-") ? .red : .green)
                            }
                            .font(.subheadline)
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.plain)
                } else {
                    Text(viewModel.error ?? "No markets available")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Markets")
        }
        .task {
            await viewModel.load()
        }
    }
}

#if DEBUG
import CVDomain
final class MockFetchMarketsUseCase: FetchMarketsUseCase {
    func execute() async throws -> [(coin: Coin, quote: CoinQuote?)] {
        [
            (Coin(symbol: "BTCUSDT", baseAsset: "BTC", quoteAsset: "USDT"), CoinQuote(symbol: "BTCUSDT", price: 27342.12, priceChangePercent: -1.2)),
            (Coin(symbol: "ETHUSDT", baseAsset: "ETH", quoteAsset: "USDT"), CoinQuote(symbol: "ETHUSDT", price: 1623.55, priceChangePercent: 2.45))
        ]
    }
}
#Preview {
    let mockUseCase = MockFetchMarketsUseCase()
    let vm = MarketsViewModel(useCase: mockUseCase)
    return MarketsView(viewModel: vm)
}
#endif
