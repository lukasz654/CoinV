//  MarketRowViewModel.swift
//  CoinVista
//
//  Created by lla.

import CVDomain
import Foundation

struct MarketRowViewModel: Identifiable, Equatable {
    let id: String
    let name: String
    let price: String
    let change: String

    init(coin: Coin, quote: CoinQuote?) {
        self.id = coin.symbol
        self.name = coin.baseAsset
        if let quote = quote {
            self.price = Self.format(decimal: quote.price)
            self.change = Self.formatChange(quote.priceChangePercent)
        } else {
            self.price = "-"
            self.change = "-"
        }
    }

    private static func format(decimal: Decimal) -> String {
        let number = NSDecimalNumber(decimal: decimal)
        return NumberFormatter.currency.string(from: number) ?? "-"
    }

    private static func formatChange(_ value: Decimal) -> String {
        let sign = value >= 0 ? "+" : ""
        let number = NSDecimalNumber(decimal: value)
        let formatted = NumberFormatter.percent.string(from: number) ?? "-"
        return sign + formatted
    }
}

private extension NumberFormatter {
    static let currency: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.maximumFractionDigits = 6
        return f
    }()

    static let percent: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .percent
        f.maximumFractionDigits = 2
        f.multiplier = 1
        return f
    }()
}
