//
//  CoreDataStack.swift
//  Tracker
//
//  Created by Sardor on 6/30/26.
//

import CoreData

final class CoreDataStack {
    // MARK: - Public Properties

    let persistentContainer: NSPersistentContainer

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: - Lifecycle

    init() {
        persistentContainer = NSPersistentContainer(name: "Tracker")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error as NSError? {
                assertionFailure("Failed to load persistent stores: \(error), \(error.userInfo)")
            }
        }
    }

    // MARK: - Public Methods

    func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            context.rollback()
            assertionFailure("Failed to save context: \(nsError), \(nsError.userInfo)")
        }
    }
}
