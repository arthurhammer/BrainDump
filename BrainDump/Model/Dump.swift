import CoreData

@objc(Dump)
class Dump: NSManagedObject {

    @NSManaged var text: String?
    @NSManaged var dateCreated: Date
    @NSManaged var dateModified: Date
    @NSManaged var isPinned: Bool

    convenience init(in context: NSManagedObjectContext, text: String? = nil, dateCreated: Date = Date(), isPinned: Bool = false) {
        self.init(context: context)
        self.text = text
        self.dateCreated = dateCreated
        self.dateModified = dateCreated
        self.isPinned = isPinned
    }
}

extension Dump {

    static func defaultFetchRequest() -> NSFetchRequest<Dump> {
        return NSFetchRequest<Dump>(entityName: String(describing: Dump.self))
    }

    static func libraryFetchRequest() -> NSFetchRequest<Dump> {
        let request = defaultFetchRequest()
        request.fetchBatchSize = 30
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(Dump.isPinned), ascending: false),
            NSSortDescriptor(key: #keyPath(Dump.dateModified), ascending: false)
        ]
        return request
    }
}

extension Dump {

    var title: String? {
        return text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: "\n", maxSplits: 1)
            .first
            .flatMap(String.init)
    }

    var body: String? {
        return text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: "\n", maxSplits: 1)
            .dropFirst()
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
