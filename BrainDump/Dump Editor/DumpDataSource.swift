import CoreData

class DumpDataSource {

    var dump: Dump? {
        didSet {
            guard dump != oldValue else { return }
            configureObserver()
            dumpDidUpdate?()
        }
    }

    var dumpDidUpdate: (() -> ())?

    private let store: CoreDataStore
    private var observer: ManagedObjectObserver<Dump>?

    init(store: CoreDataStore, dump: Dump?) {
        self.store = store
        self.dump = dump
        configureObserver()
    }

    // TODO:
    func _dumpsDataSource() -> DumpsDataSource {
        return DumpsDataSource(store: store)
    }

    func createNewDump(withText text: String? = nil) {
        dump = Dump(in: store.viewContext, text: text)
        save()
    }

    func deleteDump() {
        guard let dump = dump else { return }
        // `dump` is set to nil in the observer handler.
        store.viewContext.delete(dump)
        save()
    }

    func save() {
        store.save()
    }

    private func configureObserver() {
        guard let dump = dump else {
            observer = nil
            return
        }

        observer = ManagedObjectObserver(object: dump, context: store.viewContext) { [weak self] dump, changeType in
            if case .delete = changeType {
                // Update handler is called in `didSet`.
                self?.dump = nil
            } else {
                self?.dumpDidUpdate?()
            }
        }
    }
}
