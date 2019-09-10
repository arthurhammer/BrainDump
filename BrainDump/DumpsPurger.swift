import CoreData

class DumpsPurger {

    private let context: NSManagedObjectContext
    private let settings: Settings
    private var timer: BackgroundPausingTimer?

    init(context: NSManagedObjectContext, settings: Settings, purgeInterval: TimeInterval = 60, tolerance: TimeInterval = 15) {
        self.context = context
        self.settings = settings

        self.timer = BackgroundPausingTimer(interval: purgeInterval, tolerance: tolerance) { [weak self] in
            self?.purge()
        }
    }

    private func purge() {
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
}
