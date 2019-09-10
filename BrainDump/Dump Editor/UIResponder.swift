import UIKit

extension UIResponder {
    func becomeFirstResponder(_ become: Bool) {
        if become {
            becomeFirstResponder()
        } else {
            resignFirstResponder()
        }
    }
}
