import Foundation

extension String {
    /// nil if the receiver is only whitespace, otherwise trimmed from whitespace.
    var trimmedOrNil: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
