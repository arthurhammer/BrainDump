import CoreData
import UIKit

class EditorDataSource {

    var dump: Dump? {
        didSet {
            guard dump != oldValue else { return }
            store.setLastEditedDump(dump)
            configureObserver()
            dumpDidUpdate?()
        }
    }

    var dumpDidUpdate: (() -> ())?

    private let store: CoreDataStore
    private let settings: UserDefaults
    private var observer: ManagedObjectObserver<Dump>?

    init(store: CoreDataStore, settings: UserDefaults = .standard) {
        self.store = store
        self.settings = settings
        self.dump = try? store.fetchLastEditedDump()  // TODO

        archiveDumpIfNecessary()  // TODO
        configureObserver()
        subscribeToNotifications()
    }

    // TODO
    func _dumpsDataSource() -> DumpsDataSource {
        return DumpsDataSource(store: store)
    }

    func createNewDump(withText text: String? = nil) {
        let dump = Dump(in: store.viewContext, text: text)
        save()
        self.dump = dump
    }

    func archiveDump() {
        dump = nil
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

    @objc private func archiveDumpIfNecessary() {
        if let date = settings.createNewDumpDate, date <= Date() {
            archiveDump()
        }

        settings.createNewDumpDate = nil
    }

    @objc private func didEnterBackground() {
        settings.createNewDumpDate = settings.createNewDumpAfter.flatMap(Date().addingTimeInterval)
    }

    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(archiveDumpIfNecessary), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
}
