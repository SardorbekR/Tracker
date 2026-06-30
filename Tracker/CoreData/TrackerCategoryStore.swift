//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Sardor on 6/30/26.
//

import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerCategoryStoreDidChange()
}

final class TrackerCategoryStore: NSObject {
    // MARK: - Public Properties

    weak var delegate: TrackerCategoryStoreDelegate?

    var categories: [TrackerCategory] {
        let objects = fetchedResultsController.fetchedObjects ?? []
        return objects.compactMap { category(from: $0) }
    }

    // MARK: - Private Properties

    private let context: NSManagedObjectContext

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TrackerCategoryCoreData.title), ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        try? controller.performFetch()
        return controller
    }()

    // MARK: - Lifecycle

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }

    convenience init(coreDataStack: CoreDataStack) {
        self.init(context: coreDataStack.context)
    }

    // MARK: - Private Methods

    private func category(from categoryCoreData: TrackerCategoryCoreData) -> TrackerCategory? {
        guard let title = categoryCoreData.title else { return nil }
        let trackersCoreData = (categoryCoreData.trackers as? Set<TrackerCoreData>) ?? []
        let trackers = trackersCoreData.compactMap { $0.toTracker() }
        return TrackerCategory(title: title, trackers: trackers)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerCategoryStoreDidChange()
    }
}
