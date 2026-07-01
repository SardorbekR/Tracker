//
//  TrackerStore.swift
//  Tracker
//
//  Created by Sardor on 6/30/26.
//

import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidChange()
}

final class TrackerStore: NSObject {
    // MARK: - Public Properties

    weak var delegate: TrackerStoreDelegate?

    var trackers: [Tracker] {
        let objects = fetchedResultsController.fetchedObjects ?? []
        return objects.compactMap { $0.toTracker() }
    }

    // MARK: - Private Properties

    private let context: NSManagedObjectContext

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let request = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TrackerCoreData.name), ascending: true)
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

    // MARK: - Public Methods

    func addTracker(_ tracker: Tracker, categoryTitle: String) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.colorHex = tracker.color.hexString()
        trackerCoreData.schedule = Weekday.encode(tracker.schedule)
        trackerCoreData.category = try category(forTitle: categoryTitle)
        try context.save()
    }

    // MARK: - Private Methods

    private func category(forTitle title: String) throws -> TrackerCategoryCoreData {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCategoryCoreData.title),
            title
        )
        if let existing = try context.fetch(request).first {
            return existing
        }
        let category = TrackerCategoryCoreData(context: context)
        category.title = title
        return category
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerStoreDidChange()
    }
}

// MARK: - TrackerCoreData Mapping

extension TrackerCoreData {
    func toTracker() -> Tracker? {
        guard
            let id,
            let name,
            let emoji,
            let colorHex
        else {
            return nil
        }
        return Tracker(
            id: id,
            name: name,
            color: UIColor(hexString: colorHex),
            emoji: emoji,
            schedule: Weekday.decode(schedule)
        )
    }
}
