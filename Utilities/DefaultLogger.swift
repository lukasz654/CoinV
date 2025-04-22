//  DefaultLogger.swift
//  CoinVista
//
//  Created by lla.

import Foundation

public final class DefaultLogger: CVLogger {
    public init() {}

    public func debug(_ message: String) {
        print("[DEBUG]: \(message)")
    }

    public func info(_ message: String) {
        print("[INFO]: \(message)")
    }

    public func warning(_ message: String) {
        print("[WARNING]: \(message)")
    }

    public func error(_ message: String) {
        print("[ERROR]: \(message)")
    }
}
