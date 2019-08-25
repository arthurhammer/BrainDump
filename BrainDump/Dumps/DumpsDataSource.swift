import CoreData

class DumpsDataSource: NSObject {

    var dumpsWillChange: (() -> ())?
    var dumpDidChange: ((FetchedResultsControllerChange) -> ())?
    var dumpsDidChange: (() -> ())?

    private let store: CoreDataStore
    private let frc: NSFetchedResultsController<Dump>

    init(store: CoreDataStore) {
        self.store = store

        let request = Dump.defaultFetchRequest()
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

    func deleteDump(at index: Int) {
        let dump = frc.object(at: IndexPath(row: index, section: 0))
        store.viewContext.delete(dump)
        store.save()
    }

    func deleteAllDumps() {
        frc.fetchedObjects?.forEach(store.viewContext.delete)
        store.save()
    }
}

extension DumpsDataSource: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        dumpsWillChange?()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange object: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        let change = FetchedResultsControllerChange(object: object, type: type, indexPath: indexPath, newIndexPath: newIndexPath)
        dumpDidChange?(change)
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        dumpsDidChange?()
    }
}
