////  MarketListStateManager.swift
////  CoinVista
////
////  Created by lla.
//
//import CVDomain
//import Combine
//import Foundation
//import Utilities
//
//@MainActor
//final class MarketListStateManager {
//    @Published private(set) var allItems: [MarketRowViewModel] = []
//    private let toggleUseCase: ToggleWatchlistUseCase
//    private let logger: CVLogger
//    var cancellables = Set<AnyCancellable>()
//
//    init(toggleUseCase: ToggleWatchlistUseCase, logger: CVLogger) {
//        self.toggleUseCase = toggleUseCase
//        self.logger = logger
//    }
//
//    func updateItems(from result: [(Coin, CoinQuote?)]) {
//        self.allItems = result.map { MarketRowViewModel(coin: $0.0, quote: $0.1) }
//    }
//
//    func filter(text: String) -> [MarketRowViewModel] {
//        guard !text.isEmpty else { return allItems }
//        return allItems.filter { $0.name.lowercased().contains(text.lowercased()) }
//    }
//
//    func toggleWatchlist(for symbol: String) async {
//        do {
//            try await toggleUseCase.execute(symbol: symbol)
//            if let index = allItems.firstIndex(where: { $0.id == symbol }) {
//                var item = allItems[index]
//                item = MarketRowViewModel(
//                    coin: Coin(
//                        symbol: item.coin.symbol,
//                        baseAsset: item.coin.baseAsset,
//                        quoteAsset: item.coin.quoteAsset,
//                        isWatchlisted: !item.coin.isWatchlisted
//                    ),
//                    quote: item.quote
//                )
//                allItems[index] = item
//            }
//        } catch {
//            logger.error("Toggle failed for \(symbol): \(error)")
//        }
//    }
//}
