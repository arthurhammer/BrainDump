import CoreData

class DumpsDataSource: NSObject {

    var dumpsWillChange: (() -> ())?
    var sectionDidChange: ((FetchedResultsControllerSectionChange) -> ())?
    var dumpDidChange: ((FetchedResultsControllerObjectChange) -> ())?
    var dumpsDidChange: (() -> ())?

    private let store: CoreDataStore
    private let settings: UserDefaults
    private let frc: NSFetchedResultsController<Dump>

    init(store: CoreDataStore, fetchRequest: NSFetchRequest<Dump> = Dump.libraryFetchRequest(), settings: UserDefaults = .standard) {
        self.store = store
        self.settings = settings
        let sectionKey = fetchRequest.sortDescriptors?.first?.key ?? ""
        self.frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: store.viewContext, sectionNameKeyPath: sectionKey, cacheName: nil)

        super.init()

        frc.delegate = self
        try? frc.performFetch()
    }

    func expirationDate(for dump: Dump) -> Date? {
        guard let delay = settings.deleteArchivedDumpsAfter else { return nil }
        return dump.dateModified.addingTimeInterval(delay)
    }

    func showsHeader(forSection section: Int) -> Bool {
        return (section == 1) && (numberOfSections > 0) && (numberOfDumps(inSection: 1) > 0)
    }

    var numberOfSections: Int {
        return frc.sections?.count ?? 0
    }

    func numberOfDumps(inSection section: Int) -> Int {
        return frc.sections?[section].numberOfObjects ?? 0
    }

    func dump(at indexPath: IndexPath) -> Dump {
        return frc.object(at: indexPath)
    }

    func indexPath(of dump: Dump) -> IndexPath? {
        return frc.indexPath(forObject: dump)
    }

    func deleteDump(at indexPath: IndexPath) {
        let dump = frc.object(at: indexPath)
        store.viewContext.delete(dump)
        store.save()
    }

    func deleteAllUnpinnedDumps() {
        frc.fetchedObjects?
            .filter { !$0.isPinned }
            .forEach(store.viewContext.delete)
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

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        sectionDidChange?(.init(type: type, index: sectionIndex))
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange object: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        dumpDidChange?(.init(object: object, type: type, indexPath: indexPath, newIndexPath: newIndexPath))
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        dumpsDidChange?()
    }
}
