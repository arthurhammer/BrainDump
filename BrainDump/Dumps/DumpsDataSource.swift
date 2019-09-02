import CoreData

class DumpsDataSource: NSObject {

    var dumpsWillChange: (() -> ())?
    var dumpDidChange: ((FetchedResultsControllerChange) -> ())?
    var dumpsDidChange: (() -> ())?

    private let store: CoreDataStore
    private let frc: NSFetchedResultsController<Dump>

    init(store: CoreDataStore, fetchRequest: NSFetchRequest<Dump> = Dump.libraryFetchRequest()) {
        self.store = store
        let sectionKey = fetchRequest.sortDescriptors?.first?.key ?? ""
        self.frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: store.viewContext, sectionNameKeyPath: sectionKey, cacheName: nil)

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

    func save() {
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
