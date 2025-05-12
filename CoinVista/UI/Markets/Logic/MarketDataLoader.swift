////  MarketDataLoader.swift
////  CoinVista
////
////  Created by lla.
//
//import CVDomain
//import Foundation
//import Utilities
//
//enum MarketLoadState: Equatable {
//    case idle
//    case loading
//    case success
//    case failure
//    case offlineWithCache
//}
//
//@MainActor
//final class MarketDataLoader {
//    private let useCase: FetchMarketsUseCase
//    private let stateManager: MarketListStateManager
//    private let logger: CVLogger
//
//    private var hasLoaded = false
//
//    @Published private(set) var loadState: MarketLoadState = .idle
//    @Published private(set) var error: Error?
//    @Published private(set) var lastUpdate: Date?
//
//    init(
//        useCase: FetchMarketsUseCase,
//        stateManager: MarketListStateManager,
//        logger: CVLogger
//    ) {
//        self.useCase = useCase
//        self.stateManager = stateManager
//        self.logger = logger
//    }
//
//    func loadIfNeeded() async {
//        guard !hasLoaded else { return }
//        await load()
//    }
//
//    func retry() async {
//        hasLoaded = false
//        await load()
//    }
//
//    private func load() async {
//        loadState = .loading
//        do {
//            let result = try await useCase.execute()
//            stateManager.updateItems(from: result)
//            lastUpdate = Date()
//            loadState = .success
//            error = nil
//        } catch {
//            logger.error("Error loading markets: \(error)")
//            self.error = error
//            self.loadState = .failure
//        }
//        hasLoaded = true
//    }
//}
