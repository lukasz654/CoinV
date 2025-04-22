//  CVLogger.swift
//  CoinVista
//
//  Created by lla.

public protocol CVLogger {
    func debug(_ message: String)
    func info(_ message: String)
    func warning(_ message: String)
    func error(_ message: String)
}
