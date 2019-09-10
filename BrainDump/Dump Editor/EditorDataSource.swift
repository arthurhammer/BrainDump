import CoreData
import UIKit

class EditorDataSource {

    var dump: Dump? {
        didSet {
            guard dump != oldValue else { return }
            saveLastEditedDump()
            configureObserver()
            dumpDidUpdate?()
        }
    }

    /// Called when any of `dump`'s properties change or it is replaced with another instance.
    var dumpDidUpdate: (() -> ())?

    private let store: CoreDataStore
    private let settings: Settings
    private let center: NotificationCenter
    private var observer: ManagedObjectObserver<Dump>?

    init(store: CoreDataStore, settings: Settings, center: NotificationCenter = .default) {
        self.store = store
        self.settings = settings
        self.center = center
        self.dump = fetchLastEditedDump()

        archiveDumpIfNecessary()
        configureObserver()
        subscribeToNotifications()
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

    private func saveLastEditedDump() {
        assert(!(dump?.objectID.isTemporaryID ?? false))
        settings.lastEditedDumpURI = dump?.objectID.uriRepresentation()
    }

    private func fetchLastEditedDump() -> Dump? {
        guard let uri = settings.lastEditedDumpURI else { return nil }
        return try? store.viewContext.fetchObject(withURI: uri)
    }

    @objc private func archiveDumpIfNecessary() {
        if settings.createDumpAfter.isEnabled,
            let date = settings.createDumpOn,
            date <= Date() {

            archiveDump()
        }

        settings.createDumpOn = nil
    }

    @objc private func didEnterBackground() {
        let createAfter = settings.createDumpAfter

        if createAfter.isEnabled {
            settings.createDumpOn = Date().adding(createAfter.value)
        } else {
            settings.createDumpOn = nil
        }
    }

    @objc private func willEnterForeground() {
        archiveDumpIfNecessary()
    }

    private func subscribeToNotifications() {
        center.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        center.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
}
