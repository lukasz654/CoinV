//  ErrorView.swift
//  CoinVista
//
//  Created by lla.

import SwiftUI

public struct ErrorView: View {
    let message: String

    public init(message: String) {
        self.message = message
    }

    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            Text("Oops!")
                .font(.title)
                .fontWeight(.semibold)
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

#if DEBUG
#Preview {
    ErrorView(message: "Failed to initialize service. Please check configuration.")
}
#endif
