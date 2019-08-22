import CoreData
import UIKit

class DumpDataSource {

    private(set) lazy var dump: Dump = {
        let request = NSFetchRequest<Dump>(entityName: String(describing: Dump.self))
        request.fetchLimit = 1

        if let dump = (try? store.viewContext.fetch(request))?.first {
            return dump
        }

        let dump = Dump(in: store.viewContext)
        save()

        return dump
    }()

    private let store: CoreDataStore

    init(store: CoreDataStore) {
        self.store = store

        subscribeToNotifications()
    }

    @objc func save() {
        store.save()
    }

    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(save), name: UIApplication.willResignActiveNotification, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(save), name: UIApplication.willTerminateNotification, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(save), name: UIApplication.didEnterBackgroundNotification, object: self)
    }
}
