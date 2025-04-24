//  MarketRow.swift
//  CoinVista
//
//  Created by lla.

import SwiftUI
import CVDomain

struct MarketRow: View {
    let item: MarketRowViewModel

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(item.name)
                    .font(.headline)

                Spacer()

                if item.isWatchlisted {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
            }

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
}

#if DEBUG
#Preview("MarketRow – Watchlisted") {
    MarketRow(item: MarketRowViewModel(
        coin: Coin(
            symbol: "BTCUSDT",
            baseAsset: "BTC",
            quoteAsset: "USDT",
            isWatchlisted: true
        ),
        quote: CoinQuote(
            symbol: "BTCUSDT",
            price: 29500.12,
            priceChangePercent: -0.5
        )
    ))
}

#Preview("MarketRow – Not Watchlisted") {
    MarketRow(item: MarketRowViewModel(
        coin: Coin(
            symbol: "BTCUSDT",
            baseAsset: "BTC",
            quoteAsset: "USDT",
            isWatchlisted: false
        ),
        quote: CoinQuote(
            symbol: "BTCUSDT",
            price: 29500.12,
            priceChangePercent: -0.5
        )
    ))
}
#endif
