//  PersistenceController.swift
//  CVPersistance
//
//  Created by lla.

import CoreData
import Foundation
import Utilities

public enum PersistenceError: Error {
    case modelNotFound
    case persistentStoreLoadingFailed(Error)
    case saveFailed(Error)
    case entityNotFound(String)
}

public final class PersistenceController {
    public static let shared = PersistenceController()

    public private(set) var container: NSPersistentContainer

    public var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    public var backgroundContext: NSManagedObjectContext {
        container.newBackgroundContext()
    }

    private let logger = CVLog.shared

    private init(inMemory: Bool = false) {
        do {
            guard let modelURL = Bundle(for: Self.self).url(forResource: "CVModel", withExtension: "momd"),
                  let model = NSManagedObjectModel(contentsOf: modelURL) else {
                throw PersistenceError.modelNotFound
            }

            container = NSPersistentContainer(name: "CVModel", managedObjectModel: model)

            if inMemory {
                container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
            }

            var loadError: Error?
            container.loadPersistentStores { _, error in
                if let error = error {
                    loadError = error
                }
            }

            if let error = loadError {
                logger.error("Failed to load persistent store: \(error)")
                throw PersistenceError.persistentStoreLoadingFailed(error)
            }

            container.viewContext.automaticallyMergesChangesFromParent = true
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        } catch {
            logger.error("Persistence initialization error: \(error)")
            container = NSPersistentContainer(name: "CVModel")
        }
    }

    public func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                logger.error("Failed to save context: \(error)")
            }
        }
    }
}
