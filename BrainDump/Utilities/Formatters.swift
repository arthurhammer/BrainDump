import Foundation

class DateModifiedFormatter {

    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    func string(from date: Date) -> String {
        let isToday = Calendar.current.isDateInToday(date)
        formatter.dateStyle = isToday ? .none : .short
        return formatter.string(from: date)
    }
}

class TimeRemainingFormatter {

    private lazy var formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.maximumUnitCount = 1
        formatter.allowsFractionalUnits = true
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        return formatter
    }()

    /// If `from` exceeds `to`, `to` will be set to `from`.
    func string(from: Date, to: Date) -> String? {
        let to = max(from, to)
        return formatter.string(from: from, to: to)
    }
}

class AfterTimeFormatter {

    private lazy var formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.maximumUnitCount = 2
        formatter.unitsStyle = .short
        formatter.zeroFormattingBehavior = .dropAll
        return formatter
    }()

    func string(from components: DateComponents) -> String? {
        return formatter.string(from: components)
    }

    func localizedPhrasedString(from components: DateComponents) -> String? {
        guard let string = self.string(from: components) else { return nil }
        let format = NSLocalizedString("formatter.afterTimeUnit", value: "After %@", comment: "After <time interval>.")
        return String.localizedStringWithFormat(format, string)
    }
}
