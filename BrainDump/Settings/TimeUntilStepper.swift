import UIKit

/// A terrible abuse of `UIStepper` for stepping through nominal date component values.
/// Do not modify the `value`, `minimumValue`, `maximumValue` properties.
class TimeUntilStepper: UIStepper {

    /// The date values the stepper steps through.
    var dateValues = [DateComponents]() {
        didSet {
            guard !dateValues.isEmpty else { fatalError("Nonempty `dateValues` is required.") }
            updateRange()
        }
    }

    /// The current date value.
    /// When setting a value that is not present in `dateValues`, the value is appended to `dateValues`.
    var dateValue: DateComponents {
        get {
            guard dateValues.indices ~= index else { fatalError("Nonempty `dateValues` is required. Modifying `value`, `minimumValue`, `maximumValue` directly is not supported.")  }
            return dateValues[index]
        }
        set {
            if let index = dateValues.firstIndex(of: newValue) {
                self.index = index
            } else {
                dateValues.append(newValue)
                self.index = dateValues.indices.last!
            }
        }
    }

    /// Index of the current date value, represented by the actual numeric value.
    private var index: Int {
        get { return Int(value) }
        set { value = Double(newValue) }
    }

    private func updateRange() {
        minimumValue = 0
        maximumValue = Double(max(0, dateValues.count - 1))
        value = 0
    }
}
