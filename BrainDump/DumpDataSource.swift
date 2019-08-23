import CoreData
import UIKit

class DumpDataSource {

    let deleteAfter: TimeInterval

    private(set) var currentDump: Dump?
    private let store: CoreDataStore

    init(store: CoreDataStore, deleteAfter: TimeInterval = 24 * 60 * 60) {
        self.store = store
        self.deleteAfter = deleteAfter

        subscribeToNotifications()
        purgeExpiredDumpsIfNecessary()

        let request = NSFetchRequest<Dump>(entityName: String(describing: Dump.self))
        request.sortDescriptors = [NSSortDescriptor(key: "dateModified", ascending: false)]
        // request.fetchLimit = 1

        let result = try? store.viewContext.fetch(request)

        if let dump = result?.first {
            print("Loading existing dump")
            currentDump = dump
        } else {
            currentDump = Dump(in: store.viewContext)
        }

        save()
    }

    /// Replaces `currentDump` with the returned new instance.
    @discardableResult func createNewCurrentDump() -> Dump {
        currentDump = Dump(in: store.viewContext)
        save()
        return currentDump!
    }

    func deleteCurrentDump() {
        currentDump.flatMap(store.viewContext.delete)
        currentDump = nil
        save()
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
