//  TabBarView.swift
//  CoinVista
//
//  Created by lla.

import SwiftUI
import CVDomain
import CVCommunication
import CVPersistance
import Utilities

struct TabBarView: View {

    private let logger = CVLog.shared

    var body: some View {
        TabView {
            marketsTab
                .tabItem {
                    Label("Markets", systemImage: "chart.bar")
                }

            WatchlistView()
                .tabItem {
                    Label("Watchlist", systemImage: "star")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }

    private var marketsTab: some View {
        do {
            let service = try BinanceMarketService()
            let remote = MarketRepositoryImpl(service: service)
            let repository = CachedMarketRepository(remote: remote)
            let useCase = DefaultFetchMarketsUseCase(repository: repository)
            let viewModel = MarketsViewModel(useCase: useCase)
            return AnyView(MarketsView(viewModel: viewModel))
        } catch {
            logger.error("Failed to initialize BinanceMarketService: \(error.localizedDescription)")
            return AnyView(ErrorView(message: "Configuration error"))
        }
    }
}

#if DEBUG
#Preview("Default") {
    TabBarView()
}

#Preview("Error") {
    ErrorView(message: "Configuration error (preview)")
}
#endif
