import UIKit

extension UIAlertController {

    static func mailNotAvailable(contactAddress: String, okHandler: ((UIAlertAction) -> ())? = nil) -> UIAlertController {
        let title = NSLocalizedString("alert.mail.title", value: "This device can't send emails.", comment: "")
        let messageFormat = NSLocalizedString("alert.mail.message", value: "You can reach me at %@", comment: "E-mail address")
        let message = String.localizedStringWithFormat(messageFormat, contactAddress)
        return with(title: title, message: message, okHandler: okHandler)
    }
}

extension UIAlertController {
    static func with(title: String?, message: String? = nil, preferredStyle: UIAlertController.Style = .alert, okHandler: ((UIAlertAction) -> ())? = nil) -> UIAlertController {
        let controller = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        controller.addAction(.ok(handler: okHandler))
        return controller
    }
}

extension UIAlertAction {
    static func ok(handler: ((UIAlertAction) -> ())? = nil) -> UIAlertAction {
        let title = NSLocalizedString("alert.ok", value: "OK", comment: "")
        return UIAlertAction(title: title, style: .default, handler: handler)
    }
}

extension UIViewController {
    func presentAlert(_ controller: UIAlertController, animated: Bool = true) {
        present(controller, animated: animated)
    }
}
