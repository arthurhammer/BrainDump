import CoreData

@objc(Note)
class Note: NSManagedObject {

    @NSManaged var text: String?
    @NSManaged var dateCreated: Date
    @NSManaged var dateModified: Date
    @NSManaged var isPinned: Bool

    convenience init(in context: NSManagedObjectContext, text: String? = nil, dateCreated: Date = Date(), dateModified: Date = Date(), isPinned: Bool = false) {
        self.init(context: context)
        self.text = text
        self.dateCreated = dateCreated
        self.dateModified = dateModified
        self.isPinned = isPinned
    }

    convenience init(in context: NSManagedObjectContext, note: Note) {
        self.init(in: context, text: note.text, dateCreated: note.dateCreated, dateModified: note.dateModified, isPinned: note.isPinned)
    }
}

extension Note {

    var title: String? {
        text?.trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: "\n", maxSplits: 1)
            .first
            .flatMap(String.init)
    }

    var previewText: String? {
        text?.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n+", with: "\n", options: .regularExpression, range: nil)
            .split(separator: "\n", maxSplits: 1)
            .dropFirst()
            .joined(separator: "\n")
    }
}

extension Note {

    static func defaultRequest() -> NSFetchRequest<Note> {
        NSFetchRequest(entityName: String(describing: Note.self))
    }

    static func libraryRequest() -> NSFetchRequest<Note> {
        let request = defaultRequest()
        request.fetchBatchSize = 30
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(Note.isPinned), ascending: false),
            NSSortDescriptor(key: #keyPath(Note.dateModified), ascending: false)
        ]
        return request
    }

    static func purgeRequest(before: Date, excludingCurrentNote current: Note?) -> NSFetchRequest<Note> {
        let request = defaultRequest()
        request.includesPropertyValues = false

        if let current = current {
            request.predicate = NSPredicate(format: "(%K = false) AND (%K <= %@) AND (SELF != %@)", #keyPath(Note.isPinned), #keyPath(Note.dateModified), before as NSDate, current)
        } else {
            request.predicate = NSPredicate(format: "(%K = false) AND (%K <= %@)", #keyPath(Note.isPinned), #keyPath(Note.dateModified), before as NSDate)
        }

        return request
    }
}
