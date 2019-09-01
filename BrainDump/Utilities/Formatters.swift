import Foundation

extension DateFormatter {

    static func relativeDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }

    /// - Note: This method has side-effects on the receiver's `dateStyle` property.
    func string(forRelativeDate date: Date) -> String {
        let isToday = Calendar.current.isDateInToday(date)
        dateStyle = isToday ? .none : .short
        return string(from: date)
    }
}
