//  CrashlyticsLogger.swift
//  CoinVista
//
//  Created by lla.

import FirebaseCrashlytics
import Utilities

final class CrashlyticsLogger: CVLogger {
    func debug(_ message: String) {
        Crashlytics.crashlytics().log("DEBUG: \(message)")
    }

    func info(_ message: String) {
        Crashlytics.crashlytics().log("INFO: \(message)")
    }

    func warning(_ message: String) {
        Crashlytics.crashlytics().log("WARNING: \(message)")
    }

    func error(_ message: String) {
        Crashlytics.crashlytics().log("ERROR: \(message)")
    }
}
