import CoreData

@objc(Dump)
class Dump: NSManagedObject {

    static func defaultFetchRequest() -> NSFetchRequest<Dump> {
        return NSFetchRequest<Dump>(entityName: String(describing: Dump.self))
    }

    @NSManaged var dateCreated: Date
    @NSManaged var dateModified: Date

    @objc var text: String? {
        set {
            self.willChangeValue(forKey: #keyPath(Dump.text))
            self.setPrimitiveValue(newValue, forKey: #keyPath(Dump.text))
            self.didChangeValue(forKey: #keyPath(Dump.text))
            // Change dateModified whenever text changes.
            dateModified = Date()
        }
        get {
            self.willAccessValue(forKey: #keyPath(Dump.text))
            let text = self.primitiveValue(forKey: #keyPath(Dump.text)) as? String
            self.didAccessValue(forKey: #keyPath(Dump.text))
            return text
        }
    }

    convenience init(in context: NSManagedObjectContext, text: String? = nil, dateCreated: Date = Date()) {
        self.init(context: context)
        self.text = text
        self.dateCreated = dateCreated
        self.dateModified = dateCreated
    }
}
