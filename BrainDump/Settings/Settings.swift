import Foundation

class Settings: NotificationCenterObservable {

    private struct Keys {
        static let lastEditedDumpURI = "LastEditedDumpURI"
        static let createDumpOn = "CreateDumpOn"
        static let createDumpAfter = "CreateDumpAfter"
        static let deleteDumpsAfter = "DeleteDumpsAfter"
    }

    private let store: UserDefaults

    /// Value change notifications for the respective properties.
    struct Notifications {
        static let lastEditedDumpURI = Notification.Name(Keys.lastEditedDumpURI)
        static let createDumpOn = Notification.Name(Keys.createDumpOn)
        static let createDumpAfter = Notification.Name(Keys.createDumpAfter)
        static let deleteDumpsAfter = Notification.Name(Keys.deleteDumpsAfter)
    }

    let center: NotificationCenter

    init(store: UserDefaults = .standard, notificationCenter: NotificationCenter = .default) {
        self.store = store
        self.center = notificationCenter
    }

    var lastEditedDumpURI: URL? {
        get { return store.url(forKey: Keys.lastEditedDumpURI) }
        set {
            store.set(newValue, forKey: Keys.lastEditedDumpURI)
            post(Notifications.lastEditedDumpURI)
        }
    }

    var createDumpOn: Date? {
        get { return store.object(forKey: Keys.createDumpOn) as? Date }
        set {
            store.set(newValue, forKey: Keys.createDumpOn)
            post(Notifications.createDumpOn)
        }
    }

    var createDumpAfter: Feature<DateComponents> {
        get {
            return store.codableValue(forKey: Keys.createDumpAfter)
                ?? Settings.defaultCreateDumpAfter
        }
        set {
            store.setCodableValue(value: newValue, forKey: Keys.createDumpAfter)
            post(Notifications.createDumpAfter)
        }
    }

    var deleteDumpsAfter: Feature<DateComponents> {
        get {
            return store.codableValue(forKey: Keys.deleteDumpsAfter)
                ?? Settings.defaultDeleteDumpsAfter
        }
        set {
            store.setCodableValue(value: newValue, forKey: Keys.deleteDumpsAfter)
            post(Notifications.deleteDumpsAfter)
        }
    }
}


extension Settings {

    static let defaultCreateDumpAfter = Feature(isEnabled: true, value: DateComponents(minute: 60))
    static let defaultDeleteDumpsAfter = Feature(isEnabled: true, value: DateComponents(day: 3))

    var createDumpAfterOptions: [DateComponents] {
        return [
            .init(minute: 3), .init(minute: 5), .init(minute: 10), .init(minute: 15), .init(minute: 20), .init(minute: 30), .init(minute: 40), .init(minute: 50),
            .init(hour: 1),
            .init(hour: 2), .init(hour: 3), .init(hour: 4), .init(hour: 5), .init(hour: 6),
            .init(hour: 8), .init(hour: 10), .init(hour: 12), .init(hour: 14), .init(hour: 16), .init(hour: 18), .init(hour: 20), .init(hour: 22),
            .init(day: 1)
        ]
    }

    var deleteDumpsAfterOptions: [DateComponents] {
        return [
            .init(hour: 1), .init(hour: 2), .init(hour: 3), .init(hour: 4), .init(hour: 5), .init(hour: 6),
            .init(hour: 8), .init(hour: 10), .init(hour: 12), .init(hour: 14), .init(hour: 16), .init(hour: 18), .init(hour: 20), .init(hour: 22),
            .init(day: 1),
            .init(day: 1, hour: 12),
            .init(day: 2), .init(day: 3), .init(day: 4), .init(day: 5), .init(day: 6), .init(day: 7),
            .init(day: 10), .init(day: 14), .init(day: 30), .init(day: 60), .init(day: 90)
        ]
    }
}

private extension UserDefaults {

    func codableValue<T: Codable>(forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    func setCodableValue<T: Codable>(value: T?, forKey key: String) {
        let data = try? value.flatMap(JSONEncoder().encode)
        set(data, forKey: key)
    }
}
