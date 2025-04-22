//  MarketsViewModel.swift
//  CoinVista
//
//  Created by lla.

import CVDomain
import Foundation

@MainActor
final class MarketsViewModel: ObservableObject {
    @Published private(set) var items: [MarketRowViewModel] = []
    @Published private(set) var isLoading = false
    @Published var error: String?

    private let useCase: FetchMarketsUseCase

    init(useCase: FetchMarketsUseCase) {
        self.useCase = useCase
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await useCase.execute()
            items = result.map { MarketRowViewModel(coin: $0.coin, quote: $0.quote) }
        } catch {
            self.error = "Failed to load markets."
        }
    }
}
