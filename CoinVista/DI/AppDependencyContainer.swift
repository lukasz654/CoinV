//  AppDependencyContainer.swift
//  CoinVista
//
//  Created by lla.

import CVCommunication
import CVPersistance
import CVDomain
import Foundation
import Utilities

final class AppDependencyContainer {
    let logger: CVLogger
    let persistence: PersistenceController

    private let binanceConfiguration: BinanceConfiguration
    private let binanceService: BinanceMarketService
    private let remoteRepository: MarketRepositoryImpl
    private let cachedRepository: CachedMarketRepository

    init() {
        self.logger = CVLog.shared
        self.persistence = PersistenceController()

        self.binanceConfiguration = BinanceConfiguration()
        self.binanceService = BinanceMarketService(configuration: binanceConfiguration)
        self.remoteRepository = MarketRepositoryImpl(service: binanceService)

        self.cachedRepository = CachedMarketRepository(
            viewContext: persistence.viewContext,
            backgroundContext: persistence.backgroundContext,
            remote: remoteRepository,
            calendar: .current,
            logger: logger
        )
    }

    @MainActor
    func makeMarketStore() -> MarketStore {
        MarketStore(
            fetchUseCase: DefaultFetchMarketsUseCase(repository: cachedRepository),
            toggleWatchlistUseCase: DefaultToggleWatchlistUseCase(repository: cachedRepository),
            logger: logger
        )
    }

//    @MainActor
//    func makeWatchlistViewModel() -> WatchlistViewModel {
//        WatchlistViewModel(repository: cachedRepository, logger: logger)
//    }
}
