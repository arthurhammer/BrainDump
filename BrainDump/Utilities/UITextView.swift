import UIKit

extension UITextView {

    func startEditing(animated: Bool) {
        becomeFirstResponder()
        scrollToBottom(animated: animated)
    }

    func scrollToBottom(animated: Bool) {
        let bottom = caretRect(for: endOfDocument)
        scrollRectToVisible(bottom, animated: animated)
    }

    func scrollToTop(animated: Bool) {
        if animated {
            setContentOffset(.zero, animated: true)
        } else {
            let old = showsVerticalScrollIndicator
            showsVerticalScrollIndicator = false
            setContentOffset(.zero, animated: false)
            showsVerticalScrollIndicator = old
        }
    }
}
