import UIKit

extension UITextView {
    func scrollToBottom(animated: Bool) {
        let bottom = caretRect(for: endOfDocument)
        scrollRectToVisible(bottom, animated: animated)
    }

    func startEditing(animated: Bool) {
        becomeFirstResponder()
        scrollToBottom(animated: animated)
    }
}
