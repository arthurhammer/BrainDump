import CoreData
import UIKit

class CoreDataStore: NSPersistentContainer {

    var storeURL: URL {
        let fileName = "\(name).sqlite"
        return NSPersistentContainer.defaultDirectoryURL().appendingPathComponent(fileName)
    }

    private let center: NotificationCenter = .default

    /// Loads the store asynchronously.
    func loadStore(completion: @escaping () -> ()) {
        let description = NSPersistentStoreDescription(url: storeURL)
        description.shouldAddStoreAsynchronously = true
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
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

    func subscribeToNotifications() {
        center.addObserver(self, selector: #selector(save), name: UIApplication.willResignActiveNotification, object: nil)
        center.addObserver(self, selector: #selector(save), name: UIApplication.didEnterBackgroundNotification, object: nil)
        center.addObserver(self, selector: #selector(save), name: UIApplication.willTerminateNotification, object: nil)
    }
}

extension NSManagedObjectContext {
    /// - Warning: this will throw an unhandled (in Swift) Objective-C exception if the URL
    /// is not valid for the store. This can happen when the Core Data Model changes.
    func fetchObject<T: NSManagedObject>(withURI uri: URL) throws -> T? {
        guard let id = persistentStoreCoordinator?.managedObjectID(forURIRepresentation: uri) else { return nil }
        return try existingObject(with: id) as? T
    }
}
