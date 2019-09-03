import CoreData

class DumpsPurger {

    private let context: NSManagedObjectContext
    private let settings: UserDefaults
    private var timer: BackgroundPausingTimer?

    init(context: NSManagedObjectContext, settings: UserDefaults = .standard, purgeInterval: TimeInterval = 60, tolerance: TimeInterval = 15) {
        self.context = context
        self.settings = settings
        self.timer = BackgroundPausingTimer(interval: purgeInterval, tolerance: tolerance) { [weak self] in
            self?.purge()
        }
    }

    // TODO
    private func purge() {
        guard let purgeAfter = settings.deleteArchivedDumpsAfter else { return }
        let current = settings.lastEditedDumpURI.flatMap(context.persistentStoreCoordinator!.managedObjectID(forURIRepresentation:))

        let request = Dump.defaultFetchRequest()
        request.includesPropertyValues = false
        let purgeBefore = Date().addingTimeInterval(-purgeAfter)

        if let dump = current {
            request.predicate = NSPredicate(format: "(%K = false) AND (%K <= %@) AND (SELF != %@)", #keyPath(Dump.isPinned), #keyPath(Dump.dateModified), purgeBefore as NSDate, dump)
        } else {
            request.predicate = NSPredicate(format: "(%K = false) AND (%K <= %@)", #keyPath(Dump.isPinned), #keyPath(Dump.dateModified), purgeBefore as NSDate)
        }

        guard let results = try? context.fetch(request) else { return }

        dprint("Deleting", Date(), results.count)
        results.forEach(context.delete)
        try? context.save()  //  todo doenst check haschanges + error handling
    }
}
