import CoreData
import UIKit

class DumpsPurger {

    private let context: NSManagedObjectContext
    private let settings: UserDefaults
    private let purgeInterval: TimeInterval
    private var timer: Timer?
    private var lastPurge = Date.distantPast

    init(context: NSManagedObjectContext, settings: UserDefaults = .standard, purgeInterval: TimeInterval = 60) {
        self.context = context
        self.settings = settings
        self.purgeInterval = purgeInterval

        schedulePurging()
        subscribeToNotifications()
    }

    // TODO
    private func purge() {
        guard let purgeAfter = settings.deleteArchivedDumpsAfter else { return }
        lastPurge = Date()

        let current = settings.lastEditedDumpURI.flatMap(context.persistentStoreCoordinator!.managedObjectID(forURIRepresentation:))

        let request = Dump.defaultFetchRequest()
        request.includesPropertyValues = false
        let purgeBefore = Date().addingTimeInterval(-purgeAfter)

        if let dump = current {
            request.predicate = NSPredicate(format: "(dateModified <= %@) AND (SELF != %@)", purgeBefore as NSDate, dump)
        } else {
            request.predicate = NSPredicate(format: "dateModified <= %@", purgeBefore as NSDate)
        }

        guard let results = try? context.fetch(request) else { return }

        dprint("Deleting", Date(), results.count)
        results.forEach(context.delete)
        try? context.save()  //  todo doenst check haschanges + error handling
    }

    @objc private func schedulePurging() {
        if lastPurge.addingTimeInterval(purgeInterval) <= Date() {
            purge()
        }

        timer = Timer.scheduledTimer(withTimeInterval: purgeInterval, repeats: true) { [weak self] _ in
            self?.purge()
        }

        timer?.tolerance = 15
    }

    @objc private func stopPurging() {
        timer?.invalidate()
        timer = nil
    }

    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(stopPurging), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(schedulePurging), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
}
