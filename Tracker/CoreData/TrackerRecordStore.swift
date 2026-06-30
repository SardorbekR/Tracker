//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Sardor on 6/30/26.
//

import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func trackerRecordStoreDidChange()
}

final class TrackerRecordStore: NSObject {
    // MARK: - Public Properties

    weak var delegate: TrackerRecordStoreDelegate?

    var records: [TrackerRecord] {
        let objects = fetchedResultsController.fetchedObjects ?? []
        return objects.compactMap { record(from: $0) }
    }

    // MARK: - Private Properties

    private let context: NSManagedObjectContext

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let request = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TrackerRecordCoreData.date), ascending: true)
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

    func addRecord(trackerId: UUID, date: Date) throws {
        guard let trackerCoreData = try tracker(byId: trackerId) else { return }
        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.date = date
        recordCoreData.tracker = trackerCoreData
        try context.save()
    }

    func removeRecord(trackerId: UUID, date: Date) throws {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "tracker.id == %@ AND date == %@",
            trackerId as NSUUID,
            date as NSDate
        )
        let recordsCoreData = try context.fetch(request)
        recordsCoreData.forEach { context.delete($0) }
        try context.save()
    }

    // MARK: - Private Methods

    private func tracker(byId id: UUID) throws -> TrackerCoreData? {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as NSUUID)
        return try context.fetch(request).first
    }

    private func record(from recordCoreData: TrackerRecordCoreData) -> TrackerRecord? {
        guard
            let date = recordCoreData.date,
            let trackerId = recordCoreData.tracker?.id
        else {
            return nil
        }
        return TrackerRecord(trackerId: trackerId, date: date)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerRecordStoreDidChange()
    }
}
