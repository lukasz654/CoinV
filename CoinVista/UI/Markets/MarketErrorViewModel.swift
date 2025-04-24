//  MarketErrorViewModel.swift
//  CoinVista
//
//  Created by lla.

import Foundation
import CVCommunication
import Utilities

struct MarketErrorViewModel {
    private static let logger = CVLog.shared
    
    static func message(for error: Error) -> String {
        if let error = error as? BinanceServiceError {
            switch error {
            case .invalidURL:
                return "Invalid URL"
            case .requestFailed(let err):
                return "Request failed: \(err.localizedDescription)"
            case .invalidResponse(let code, let message):
                return message ?? "API error: \(code)"
            case .decodingFailed:
                return "Failed to decode server response"
            @unknown default:
                Self.logger.error("Unexpected error case in BinanceServiceError")
            }
        }

        return "An unexpected error occurred"
    }
}
