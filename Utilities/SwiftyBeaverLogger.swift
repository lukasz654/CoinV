//  SwiftyBeaverLogger.swift
//  CoinVista
//
//  Created by lla.

import SwiftyBeaver

public final class SwiftyBeaverLogger: CVLogger {
    private let log = SwiftyBeaver.self

    public init() {
        let console = ConsoleDestination()
        log.addDestination(console)
    }

    public func debug(_ message: String) {
        log.debug(message)
    }

    public func info(_ message: String) {
        log.info(message)
    }

    public func warning(_ message: String) {
        log.warning(message)
    }

    public func error(_ message: String) {
        log.error(message)
    }
}
