//  MarketsView.swift
//  CoinVista
//
//  Created by lla.

import SwiftUI

struct MarketsView: View {
    var body: some View {
        NavigationStack {
            Text("Markets")
                .navigationTitle("Markets")
        }
    }
}

#if DEBUG
#Preview {
    MarketsView()
}
#endif
