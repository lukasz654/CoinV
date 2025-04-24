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

    @StateObject private var viewModel: MarketsViewModel

       init() {
           let configuration = BinanceConfiguration()
           let service = BinanceMarketService(configuration: configuration)
           let remote = MarketRepositoryImpl(service: service)
           let repository = CachedMarketRepository(remote: remote)
           let fetchUseCase = DefaultFetchMarketsUseCase(repository: repository)
           let toggleUseCase = DefaultToggleWatchlistUseCase(repository: repository)
           let viewModel = MarketsViewModel(useCase: fetchUseCase,toggleWatchlistUseCase: toggleUseCase)
           _viewModel = StateObject(wrappedValue:
                                        MarketsViewModel(
                                            useCase: fetchUseCase,
                                            toggleWatchlistUseCase: toggleUseCase)
           )
       }

    var body: some View {
        TabView {
            MarketsView(viewModel: viewModel)
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
}

#if DEBUG
#Preview("Default") {
    TabBarView()
}

#Preview("Error") {
    ErrorView(message: "Configuration error (preview)")
}
#endif
