import Foundation

extension UserDefaults {

    private struct Key {
        static let lastEditedDump = "LastDump"
    }

    var lastEditedDumpURI: URL? {
        get { return url(forKey: Key.lastEditedDump) }
        set { set(newValue, forKey: Key.lastEditedDump) }
    }
}
