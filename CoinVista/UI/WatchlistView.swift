//  WatchlistView.swift
//  CoinVista
//
//  Created by lla.

import SwiftUI

struct WatchlistView: View {
    var body: some View {
        NavigationStack {
            Text("Watchlist")
                .navigationTitle("Watchlist")
        }
    }
}
#if DEBUG
#Preview {
    WatchlistView()
}
#endif
