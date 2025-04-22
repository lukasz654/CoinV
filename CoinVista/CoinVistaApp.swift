//
//  CoinVistaApp.swift
//  CoinVista
//
//  Created by lla on 17/04/2025.
//

import SwiftUI

@main
struct CoinVistaApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            TabBarView()
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
