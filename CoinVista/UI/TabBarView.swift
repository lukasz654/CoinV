//  TabBarView.swift
//  CoinVista
//
//  Created by lla.

import Utilities
import SwiftUI

struct TabBarView: View {

    private let logger: CVLogger = CompositeLogger([
            DefaultLogger(),
            SwiftyBeaverLogger()
            // + CrashlyticsLogger()
        ])

    var body: some View {
        TabView {
            MarketsView()
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
#Preview {
    TabBarView()
}
#endif
