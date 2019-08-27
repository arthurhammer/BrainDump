import CoreData
import UIKit

class CoreDataStore: NSPersistentContainer {

    var lastEditedDumpDataSource = UserDefaults.standard

    func fetchLastEditedDump() throws -> Dump? {
        guard let uri = lastEditedDumpDataSource.lastEditedDumpURI else { return nil }
        return try viewContext.fetchObject(withURI: uri)
    }

    func setLastEditedDump(_ dump: Dump?) {
        assert(!(dump?.objectID.isTemporaryID == true))
        lastEditedDumpDataSource.lastEditedDumpURI = dump?.objectID.uriRepresentation()
    }
}

extension NSPersistentContainer {

    var storeURL: URL {
        let fileName = "\(name).sqlite"
        return NSPersistentContainer.defaultDirectoryURL().appendingPathComponent(fileName)
    }

    /// Loads the store asynchronously.
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

    /// Saves the `viewContext`.
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

extension NSManagedObjectContext {
    func fetchObject<T: NSManagedObject>(withURI uri: URL) throws -> T? {
        guard let id = persistentStoreCoordinator?.managedObjectID(forURIRepresentation: uri) else { return nil }
        return try existingObject(with: id) as? T
    }
}
