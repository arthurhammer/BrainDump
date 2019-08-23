import CoreData

class DumpsDataSource: NSObject {

    private let store: CoreDataStore
    private let frc: NSFetchedResultsController<Dump>

    var dumpDidChange: ((FetchedResultsControllerChange) -> ())?

    init(store: CoreDataStore) {
        self.store = store

        // todo
        let request = NSFetchRequest<Dump>(entityName: String(describing: Dump.self))
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Dump.dateModified), ascending: false)]
        self.frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: store.viewContext, sectionNameKeyPath: nil, cacheName: nil)

        super.init()

        frc.delegate = self
        try? frc.performFetch()
    }

    func numberOfDumps() -> Int {
        return frc.sections?.first?.numberOfObjects ?? 0
    }

    func dump(at index: Int) -> Dump {
        return frc.object(at: IndexPath(row: index, section: 0))
    }
}

extension DumpsDataSource: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange object: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        let change = FetchedResultsControllerChange(object: object, type: type, indexPath: indexPath, newIndexPath: newIndexPath)
        dumpDidChange?(change)
    }
}
