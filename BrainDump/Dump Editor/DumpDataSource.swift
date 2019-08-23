import CoreData
import UIKit

// Stack Overflow: "Leave the General Problem for later, if it may ever be necessary and worth the effort"
// When changing interval: how to notify user some notes might be deleted right now?

class DumpDataSource {

    var didDeleteDump: ((Dump) -> ())?  // WRONG: Called for ANY dump
    let deleteAfter: TimeInterval

    private(set) var currentDump: Dump?
    private let store: CoreDataStore

    init(store: CoreDataStore, deleteAfter: TimeInterval = 24 * 60 * 60) {
        self.store = store
        self.deleteAfter = deleteAfter

        subscribeToNotifications()
        purgeExpiredDumpsIfNecessary()

        // Loads any one dump, not sorted or sth
        let request = NSFetchRequest<Dump>(entityName: String(describing: Dump.self))
        request.sortDescriptors = [NSSortDescriptor(key: "dateModified", ascending: false)]
        // request.fetchLimit = 1

        let result = try? store.viewContext.fetch(request)
        print("Fetched: ", result?.count ?? 0, result ?? [])

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
        print("Clean")
        let purgeBefore = Date().addingTimeInterval(.init(-deleteAfter))
        let request = NSFetchRequest<Dump>(entityName: String(describing: Dump.self))
        request.predicate = NSPredicate(format: "dateModified <= %@", purgeBefore as NSDate)

        guard let result = try? store.viewContext.fetch(request) else { return }
        print("Deleting:", result)

        result.forEach(store.viewContext.delete)
        save()
        result.forEach { didDeleteDump?($0) }
    }
}
