import UIKit

typealias ActionHandler = (UIAlertAction) -> ()

extension UIAlertController {

    static func deleteAllUnpinnedNotes(cancelHandler: ActionHandler? = nil, deleteHandler: @escaping ActionHandler) -> UIAlertController {
        let title = NSLocalizedString("alert.library.deleteUnpinned.title", value: "Clear Thoughts?", comment: "Unpinned thoughts deletion confirmation title")
        let message = NSLocalizedString("alert.library.deleteUnpinned.messge", value: "Give room to new ones.", comment: "Unpinned thoughts deletion confirmation message")

        let controller = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        controller.addAction(.cancel(handler: cancelHandler))
        controller.addAction(.clear(handler: deleteHandler))
        return controller
    }

    static func mailNotAvailable(contactAddress: String, okHandler: ActionHandler? = nil) -> UIAlertController {
        let title = NSLocalizedString("alert.mail.title", value: "This device can't send emails.", comment: "")
        let messageFormat = NSLocalizedString("alert.mail.message", value: "You can reach me at %@", comment: "E-mail address")
        let message = String.localizedStringWithFormat(messageFormat, contactAddress)

        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(.ok(handler: okHandler))
        return controller
    }
}

extension UIAlertAction {
    static func ok(handler: ActionHandler? = nil) -> UIAlertAction {
        let title = NSLocalizedString("alert.ok", value: "OK", comment: "")
        return UIAlertAction(title: title, style: .default, handler: handler)
    }

    static func cancel(handler: ActionHandler? = nil) -> UIAlertAction {
        let title = NSLocalizedString("alert.cancel", value: "Cancel", comment: "")
        return UIAlertAction(title: title, style: .cancel, handler: handler)
    }

    static func clear(handler: @escaping ActionHandler) -> UIAlertAction {
        let title = NSLocalizedString("alert.delete", value: "Clear", comment: "")
        return UIAlertAction(title: title, style: .destructive, handler: handler)
    }
}

extension UIViewController {
    func presentAlert(_ controller: UIAlertController, animated: Bool = true) {
        present(controller, animated: animated)
    }
}
