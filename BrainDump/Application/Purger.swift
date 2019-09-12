import CoreData

/// Purges expired dumps at regular intervals. Currently, only context associated with the
/// main queue are supported. Fetching and purging is perfomed on the main queue.
class Purger {

    private let context: NSManagedObjectContext
    private let settings: Settings
    private var timer: BackgroundPausingTimer?

    init(context: NSManagedObjectContext, settings: Settings, purgeInterval: TimeInterval = 60, tolerance: TimeInterval = 15) {
        self.context = context
        self.settings = settings

        self.timer = BackgroundPausingTimer(interval: purgeInterval, tolerance: tolerance) { [weak self] in
            self?.purge()
        }

        observeSettings()
    }

    @objc private func purge() {
        let deleteAfter = settings.deleteDumpsAfter

        guard deleteAfter.isEnabled,
            let deleteBefore = Date().subtracting(deleteAfter.value) else { return }

        let currentDump: Dump? = try? settings.lastEditedDumpURI.flatMap(context.fetchObject(withURI:))
        let request = Dump.purgeRequest(before: deleteBefore, excludingCurrentDump: currentDump)

        guard let results = try? context.fetch(request),
            !results.isEmpty else { return }

        results.forEach(context.delete)
        try? context.save()
    }

    private func observeSettings() {
        // Purge immediately when purge settings change.
        settings.addObserver(self, selector: #selector(purge), name: Settings.Notifications.deleteDumpsAfter)
    }
}
