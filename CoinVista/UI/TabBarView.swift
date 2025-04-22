//  TabBarView.swift
//  CoinVista
//
//  Created by lla.

import SwiftUI
import CVDomain
import CVCommunication
import Utilities

struct TabBarView: View {

    private let logger: CVLogger = CompositeLogger([
        DefaultLogger(),
        SwiftyBeaverLogger()
    ])

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
        let service = BinanceMarketService()
        let repository = MarketRepositoryImpl(service: service)
        let useCase = DefaultFetchMarketsUseCase(repository: repository)
        let viewModel = MarketsViewModel(useCase: useCase)
        return MarketsView(viewModel: viewModel)
    }
}

#if DEBUG
#Preview {
    TabBarView()
}
#endif
