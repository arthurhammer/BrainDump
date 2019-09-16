import Foundation

class Settings: NotificationCenterObservable {

    private struct Keys {
        static let lastEditedNoteURI = "LastEditedNoteURI"
        static let createNoteOn = "CreateNoteOn"
        static let createNoteAfter = "CreateNoteAfter"
        static let deleteNotesAfter = "DeleteNotesAfter"
    }

    /// Value change notifications for the respective properties.
    struct Notifications {
        static let lastEditedNoteURI = Notification.Name(Keys.lastEditedNoteURI)
        static let createNoteOn = Notification.Name(Keys.createNoteOn)
        static let createNoteAfter = Notification.Name(Keys.createNoteAfter)
        static let deleteNotesAfter = Notification.Name(Keys.deleteNotesAfter)
    }

    private let store: UserDefaults
    let center: NotificationCenter

    init(store: UserDefaults = .standard, notificationCenter: NotificationCenter = .default) {
        self.store = store
        self.center = notificationCenter
    }

    var lastEditedNoteURI: URL? {
        get { return store.url(forKey: Keys.lastEditedNoteURI) }
        set {
            store.set(newValue, forKey: Keys.lastEditedNoteURI)
            post(Notifications.lastEditedNoteURI)
        }
    }

    var createNoteOn: Date? {
        get { return store.object(forKey: Keys.createNoteOn) as? Date }
        set {
            store.set(newValue, forKey: Keys.createNoteOn)
            post(Notifications.createNoteOn)
        }
    }

    var createNoteAfter: Feature<DateComponents> {
        get {
            return store.codableValue(forKey: Keys.createNoteAfter)
                ?? Settings.defaultCreateNoteAfter
        }
        set {
            store.setCodableValue(value: newValue, forKey: Keys.createNoteAfter)
            post(Notifications.createNoteAfter)
        }
    }

    var deleteNotesAfter: Feature<DateComponents> {
        get {
            return store.codableValue(forKey: Keys.deleteNotesAfter)
                ?? Settings.defaultDeleteNotesAfter
        }
        set {
            store.setCodableValue(value: newValue, forKey: Keys.deleteNotesAfter)
            post(Notifications.deleteNotesAfter)
        }
    }
}

extension Settings {

    static let defaultCreateNoteAfter = Feature(isEnabled: true, value: DateComponents(minute: 60))
    static let defaultDeleteNotesAfter = Feature(isEnabled: true, value: DateComponents(day: 3))

    var createNoteAfterOptions: [DateComponents] {
        return [
            .init(minute: 3), .init(minute: 5), .init(minute: 10), .init(minute: 15), .init(minute: 20), .init(minute: 30), .init(minute: 40), .init(minute: 50),
            .init(hour: 1), .init(hour: 2), .init(hour: 3), .init(hour: 4), .init(hour: 5), .init(hour: 6),
            .init(hour: 8)
        ]
    }

    var deleteNotesAfterOptions: [DateComponents] {
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
