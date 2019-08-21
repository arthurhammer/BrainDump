import CoreData

class CoreDataStore: NSPersistentContainer {

    private(set) lazy var dump: Dump = {
        let request = NSFetchRequest<Dump>(entityName: String(describing: Dump.self))
        request.fetchLimit = 1

        if let dump = (try? viewContext.fetch(request))?.first {
            return dump
        }

        let dump = Dump(in: viewContext)
        save()

        return dump
    }()

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
            completion()
        }
    }

    func save() {
        guard viewContext.hasChanges else { return }

        do {
            try viewContext.save()
        } catch let error as NSError {
            // Unrecoverable. No need to inform user, just crash.
            fatalError("Unresolved error saving context \(error), \(error.userInfo)")
        }
    }
}
