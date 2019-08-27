import CoreData

@objc(Dump)
class Dump: NSManagedObject {

    static func defaultFetchRequest() -> NSFetchRequest<Dump> {
        return NSFetchRequest<Dump>(entityName: String(describing: Dump.self))
    }

    @NSManaged var text: String?
    @NSManaged var dateCreated: Date
    @NSManaged var dateModified: Date

    convenience init(in context: NSManagedObjectContext, text: String? = nil, dateCreated: Date = Date()) {
        self.init(context: context)
        self.text = text
        self.dateCreated = dateCreated
        self.dateModified = dateCreated
    }
}
