//  CompositeLogger.swift
//  CoinVista
//
//  Created by lla.

public enum CVLog {
    public static let shared: CVLogger = CompositeLogger([
        DefaultLogger(),
        SwiftyBeaverLogger()
    ])
}

public final class CompositeLogger: CVLogger {
    private let loggers: [CVLogger]

    public init(_ loggers: [CVLogger]) {
        self.loggers = loggers
    }

    public func debug(_ message: String) {
        loggers.forEach { $0.debug(message) }
    }

    public func info(_ message: String) {
        loggers.forEach { $0.info(message) }
    }

    public func warning(_ message: String) {
        loggers.forEach { $0.warning(message) }
    }

    public func error(_ message: String) {
        loggers.forEach { $0.error(message) }
    }
}
