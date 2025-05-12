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

    @StateObject private var viewModel: MarketStore

    init(container: AppDependencyContainer = AppDependencyContainer()) {
        _viewModel = StateObject(wrappedValue: container.makeMarketStore())
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
