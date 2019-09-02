import UIKit

class EditorTextView: UITextView {

    private let textInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    private let fontSize: CGFloat = 16  // TODO: size categories
    private let lineHeightMultiple: CGFloat = 1.2

    override func awakeFromNib() {
        super.awakeFromNib()

        subscribeToNotifications()
        textContainerInset = textInsets

        let font = UIFont.systemFont(ofSize: fontSize)
        let style = NSMutableParagraphStyle()
        // When setting either line height or line spacing the caret and selection markers
        // will be off to the top or bottom. To center the caret, balance both spaces.
        let (multiple, spacing) = font.adjustedLineHeightMultipleAndSpacing(forPreferredMultiple: lineHeightMultiple)

        style.lineHeightMultiple = multiple
        style.lineSpacing = spacing

        typingAttributes = [
            .font: font,
            .paragraphStyle: style
        ]
    }
}

// #MARK: Keyboard Handling

private extension EditorTextView {

    func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey],
            let keyboardHeight = (keyboardFrame as? NSValue)?.cgRectValue.size.height else { return }

        contentInset.bottom = keyboardHeight
        scrollIndicatorInsets.bottom = keyboardHeight
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        contentInset = .zero
        scrollIndicatorInsets = .zero
    }
}
