import Foundation

extension UserDefaults {

    private struct Key {
        static let lastEditedDump = "LastDump"
        static let deleteArchivedDumpsAfter = "DeleteArchivedDumpsAfter"
        static let createNewDumpAfter = "CreateNewDumpAfter"
        static let createNewDumpDate = "CreateNewDumpDate"
    }

    var lastEditedDumpURI: URL? {
        get { return url(forKey: Key.lastEditedDump) }
        set { set(newValue, forKey: Key.lastEditedDump) }
    }

    var deleteArchivedDumpsAfter: TimeInterval? {
        get { return double(forKey: Key.deleteArchivedDumpsAfter) }
        set { set(newValue, forKey: Key.deleteArchivedDumpsAfter) }
    }

    var createNewDumpAfter: TimeInterval? {
        get { return double(forKey: Key.createNewDumpAfter) }
        set { set(newValue, forKey: Key.createNewDumpAfter) }
    }

    var createNewDumpDate: Date? {
        get { return object(forKey: Key.createNewDumpDate) as? Date }
        set { set(newValue, forKey: Key.createNewDumpDate) }
    }
}
