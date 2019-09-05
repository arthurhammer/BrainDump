import Foundation

extension UserDefaults {

    struct Key {
        static let lastEditedDump = "LastEditedDump"
        static let isCreateNewDumpAfterEnabled = "IsCreateNewDumpAfterEnabled"
        static let createNewDumpAfter = "CreateNewDumpAfter"
        static let createNewDumpOn = "CreateNewDumpOn"
        static let isDeleteOldDumpsAfterEnabled = "IsDeleteOldDumpsAfterEnabled"
        static let deleteOldDumpsAfter = "DeleteOldDumpsAfter"
    }

    var lastEditedDumpURI: URL? {
        get { return url(forKey: Key.lastEditedDump) }
        set { set(newValue, forKey: Key.lastEditedDump) }
    }

    var isCreateNewDumpAfterEnabled: Bool {
        get { return boolIfPresent(forKey: Key.isCreateNewDumpAfterEnabled) ?? true }
        set { set(newValue, forKey: Key.isCreateNewDumpAfterEnabled) }
    }

    var createNewDumpAfter: DateComponents {
        get { return dateComponents(forKey: Key.createNewDumpAfter) ?? UserDefaults.defaultCreateNewDumpAfterOption }
        set { set(newValue, forKey: Key.createNewDumpAfter) }
    }

    var createNewDumpOn: Date? {
        get { return object(forKey: Key.createNewDumpOn) as? Date }
        set { set(newValue, forKey: Key.createNewDumpOn) }
    }

    var isDeleteOldDumpsAfterEnabled: Bool {
        get { return boolIfPresent(forKey: Key.isDeleteOldDumpsAfterEnabled) ?? true }
        set { set(newValue, forKey: Key.isDeleteOldDumpsAfterEnabled) }
    }

    var deleteOldDumpsAfter: DateComponents {
        get { return dateComponents(forKey: Key.deleteOldDumpsAfter) ?? UserDefaults.defaultDeleteOldDumpsAfterOption }
        set { set(newValue, forKey: Key.deleteOldDumpsAfter) }
    }
}

extension UserDefaults {

    static let defaultCreateNewDumpAfterOption = DateComponents(minute: 60)
    static let defaultDeleteOldDumpsAfterOption = DateComponents(day: 3)

    var createNewDumpAfterOptions: [DateComponents] {
        return [
            .init(minute: 3), .init(minute: 5), .init(minute: 10), .init(minute: 15), .init(minute: 20), .init(minute: 30), .init(minute: 40), .init(minute: 50), .init(minute: 60),
            .init(hour: 1, minute: 30),
            .init(hour: 2), .init(hour: 3), .init(hour: 4), .init(hour: 5), .init(hour: 6),
            .init(hour: 8), .init(hour: 10), .init(hour: 12), .init(hour: 14), .init(hour: 16), .init(hour: 18), .init(hour: 20), .init(hour: 22),
            .init(day: 1)
        ]
    }

    var deleteOldDumpsAfterOptions: [DateComponents] {
        return [
            .init(minute: 30), .init(minute: 40), .init(minute: 50), .init(minute: 60),
            .init(hour: 1, minute: 30),
            .init(hour: 2), .init(hour: 3), .init(hour: 4), .init(hour: 5), .init(hour: 6),
            .init(hour: 8), .init(hour: 10), .init(hour: 12), .init(hour: 14), .init(hour: 16), .init(hour: 18), .init(hour: 20), .init(hour: 22),
            .init(day: 1),
            .init(day: 1, hour: 12),
            .init(day: 2), .init(day: 3), .init(day: 4), .init(day: 5), .init(day: 6), .init(day: 7),
            .init(day: 10), .init(day: 14), .init(day: 30), .init(day: 60), .init(day: 90)
        ]
    }
}

extension UserDefaults {

    func hasKey(_ key: String) -> Bool {
        return object(forKey: key) != nil
    }

    /// In contrast to `double(forKey:)` returns nil if the key was not found.
    func doubleIfPresent(forKey key: String) -> Double? {
        return hasKey(key) ? double(forKey: key) : nil
    }

    /// In contrast to `bool(forKey:)` returns nil if the key was not found.
    func boolIfPresent(forKey key: String) -> Bool? {
        return hasKey(key) ? bool(forKey: key) : nil
    }

    func dateComponents(forKey key: String) -> DateComponents? {
        guard let data = data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(DateComponents.self, from: data)
    }

    func set(_ value: DateComponents?, forKey key: String) {
        let data = try? value.flatMap(JSONEncoder().encode)
        set(data, forKey: key)
    }
}
