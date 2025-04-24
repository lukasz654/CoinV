//  MarketRowViewModel.swift
//  CoinVista
//
//  Created by lla.

import CVDomain
import Foundation

struct MarketRowViewModel: Identifiable, Equatable {
    let id: String
    let coin: Coin
    let quote: CoinQuote?

    var name: String { coin.baseAsset }
    var isWatchlisted: Bool { coin.isWatchlisted }

    var price: String {
        guard let quote else {
            return "-"
        }
        return Self.format(decimal: quote.price, asset: coin.quoteAsset)
    }

    var change: String {
        guard let quote else {
            return "-"
        }
        return Self.formatChange(quote.priceChangePercent)
    }

    init(coin: Coin, quote: CoinQuote?) {
        self.id = coin.symbol
        self.coin = coin
        self.quote = quote
    }

    private static func format(decimal: Decimal, asset: String) -> String {
        let number = NSDecimalNumber(decimal: decimal)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 8
        formatter.minimumFractionDigits = 2
        let value = formatter.string(from: number) ?? "-"
        return value + " " + asset
    }

    private static func formatChange(_ value: Decimal) -> String {
        let sign = value >= 0 ? "+" : ""
        let number = NSDecimalNumber(decimal: value)
        let formatted = NumberFormatter.percent.string(from: number) ?? "-"
        return sign + formatted
    }
}

private extension NumberFormatter {
    static let percent: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .percent
        f.maximumFractionDigits = 2
        f.multiplier = 1
        return f
    }()
}
