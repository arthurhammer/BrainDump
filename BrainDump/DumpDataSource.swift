import CoreData
import UIKit

class DumpDataSource {

    let deleteAfter: TimeInterval

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

    init(store: CoreDataStore, deleteAfter: TimeInterval = 24 * 60 * 60) {
        self.store = store
        self.deleteAfter = deleteAfter

        subscribeToNotifications()
        purgeExpiredDumpsIfNecessary()
    }

    @objc func save() {
        store.save()
    }

    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(save), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(save), name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(save), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    private func purgeExpiredDumpsIfNecessary() {
        let purgeBefore = Date().addingTimeInterval(.init(-deleteAfter))
        let request = NSFetchRequest<Dump>(entityName: String(describing: Dump.self))
        request.predicate = NSPredicate(format: "dateModified <= %@", purgeBefore as NSDate)

        guard let result = try? store.viewContext.fetch(request) else { return }

        result.forEach(store.viewContext.delete)
        save()
    }
}
