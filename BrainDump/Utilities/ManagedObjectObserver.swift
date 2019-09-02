import CoreData

/// Observes a single NSManagedObject for changes.
class ManagedObjectObserver<T>: NSObject, NSFetchedResultsControllerDelegate where T: NSManagedObject {

    enum ChangeType {
        case update
        case delete
    }

    private let frc: NSFetchedResultsController<T>
    private let changeHandler: (T, ChangeType) -> ()

    init(object: T, context: NSManagedObjectContext, changeHandler: @escaping (T, ChangeType) -> ()) {
        self.changeHandler = changeHandler
        let request = fetchRequest(for: object)
        self.frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)

        super.init()

        frc.delegate = self
        try? frc.performFetch()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange object: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let object = object as? T,
            let change = ChangeType(type) else { return }

        changeHandler(object, change)
    }
}

private extension ManagedObjectObserver.ChangeType {
    init?(_ type: NSFetchedResultsChangeType) {
        switch type {
        case .update: self = .update
        case .delete: self = .delete
        default: return nil
        }
    }
}

private func fetchRequest<T>(for object: T) -> NSFetchRequest<T> where T: NSManagedObject {
    let request = NSFetchRequest<T>(entityName: String(describing: T.self))
    request.predicate = NSPredicate(format: "SELF = %@", object)
    request.fetchLimit = 1
    // Unused dummy as frc requires a sort descriptor.
    request.sortDescriptors = [NSSortDescriptor(key: "objectID", ascending: true)]
    return request
}
