import CoreData

@objc(Dump)
class Dump: NSManagedObject {

    @objc var text: String? {
        set {
            self.willChangeValue(forKey: #keyPath(Dump.text))
            self.setPrimitiveValue(newValue, forKey: #keyPath(Dump.text))
            self.didChangeValue(forKey: #keyPath(Dump.text))
            dateModified = Date()
        }
        get {
            self.willAccessValue(forKey: #keyPath(Dump.text))
            let text = self.primitiveValue(forKey: #keyPath(Dump.text)) as? String
            self.didAccessValue(forKey: #keyPath(Dump.text))
            return text
        }
    }

    @NSManaged var dateCreated: Date
    @NSManaged var dateModified: Date

    convenience init(in context: NSManagedObjectContext, text: String? = nil, dateCreated: Date = Date()) {
        self.init(context: context)
        self.text = text
        self.dateCreated = dateCreated
        self.dateModified = dateCreated
    }
}
