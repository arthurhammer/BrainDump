import CoreData
import UIKit

class CoreDataStore: NSPersistentContainer {

    var storeURL: URL {
        return CoreDataStore.defaultDirectoryURL().appendingPathComponent("\(name).sqlite")
    }

    func loadStore(completion: @escaping () -> ()) {
        let description = NSPersistentStoreDescription(url: storeURL)
        description.shouldAddStoreAsynchronously = true
        persistentStoreDescriptions = [description]

        loadPersistentStores { description, error in
            if let error = error as NSError? {
                // Unrecoverable. No need to inform user, just crash.
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }

            self.viewContext.automaticallyMergesChangesFromParent = true
            self.subscribeToNotifications()
            completion()
        }
    }

    @objc func save() {
        guard viewContext.hasChanges else { return }

        do {
            try viewContext.save()
        } catch let error as NSError {
            // Unrecoverable. No need to inform user, just crash.
            fatalError("Unresolved error saving context \(error), \(error.userInfo)")
        }
    }

    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(save), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(save), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(save), name: UIApplication.willTerminateNotification, object: nil)
    }
}
