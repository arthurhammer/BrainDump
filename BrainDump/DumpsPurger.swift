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
        guard settings.isDeleteOldDumpsAfterEnabled else { return }

        let now = Date()
        let deleteWithin = settings.deleteOldDumpsAfter.negative

        guard let deleteBefore = Calendar.current.date(byAdding: deleteWithin, to: now) else {
            dprint("Could not create date from: ", now, time)
            return
        }

        dprint(time, now, deleteBefore)

        // TODO: no
        let currentDump = settings.lastEditedDumpURI.flatMap(context.persistentStoreCoordinator!.managedObjectID(forURIRepresentation:))
        let request = Dump.defaultFetchRequest()
        request.includesPropertyValues = false

        if let dump = currentDump {
            request.predicate = NSPredicate(format: "(%K = false) AND (%K <= %@) AND (SELF != %@)", #keyPath(Dump.isPinned), #keyPath(Dump.dateModified), deleteBefore as NSDate, dump)
        } else {
            request.predicate = NSPredicate(format: "(%K = false) AND (%K <= %@)", #keyPath(Dump.isPinned), #keyPath(Dump.dateModified), deleteBefore as NSDate)
        }

        guard let results = try? context.fetch(request),
            !results.isEmpty else { return }

        dprint("Deleting", now, results.count)
        results.forEach(context.delete)
        try? context.save()
    }
}

extension DateComponents {
    var negative: DateComponents {
        let flip: (Int?) -> (Int?) = { $0.flatMap { -$0 } }
        return DateComponents(calendar: calendar, timeZone: timeZone, era: flip(era), year: flip(year), month: flip(month), day: flip(day), hour: flip(hour), minute: flip(minute), second: flip(second), nanosecond: flip(nanosecond))
    }
}
