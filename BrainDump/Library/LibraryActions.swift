import UIKit

// MARK: - Actions

class PinAction {
    let note: Note

    init(note: Note) {
        self.note = note
    }

    func perform() {
        DispatchQueue.main.async {
            guard !self.note.isDeleted else { return }
            self.note.isPinned = !self.note.isPinned
        }
    }
}

class DeleteAction {
    let note: Note
    let dataSource: LibraryDataSource

    init(note: Note, dataSource: LibraryDataSource) {
        self.note = note
        self.dataSource = dataSource
    }

    func perform() {
        DispatchQueue.main.async {
            self.dataSource.delete(self.note)
        }
    }
}

class DuplicateAction {
    let note: Note
    let dataSource: LibraryDataSource

    init(note: Note, dataSource: LibraryDataSource) {
        self.note = note
        self.dataSource = dataSource
    }

    func perform() {
        DispatchQueue.main.async {
            self.dataSource.duplicate(self.note)
        }
    }
}

class ShareAction {
    let note: Note
    let presentingViewController: UIViewController

    init(note: Note, presentingViewController: UIViewController) {
        self.note = note
        self.presentingViewController = presentingViewController
    }

    func perform() {
        DispatchQueue.main.async {
            let text = self.note.text ?? ""
            let controller = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            self.presentingViewController.present(controller, animated: true)
        }
    }
}

// MARK: - Configuration

extension PinAction {

    func menuAction() -> UIAction {
        let title = note.isPinned ? NSLocalizedString("Unpin", comment: "") : NSLocalizedString("Pin", comment: "")
        let image = note.isPinned ? UIImage(systemName: "pin.slash") : UIImage(systemName: "pin")

        return UIAction(title: title, image: image) { _ in
            // Strong self capture so action gets retained until it is performed.
            self.perform()
        }
    }

    func swipeAction() -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: nil) { _, _, completion in
            self.perform()
            completion(true)
        }

        let imageName = note.isPinned ? "pin.slash.fill" : "pin.fill"
        action.image = UIImage(systemName: imageName, withConfiguration: Style.swipeActionImageConfiguration)
        action.backgroundColor = .systemOrange
        return action
    }
}

extension DeleteAction {

    func menuAction() -> UIAction {
        let title = NSLocalizedString("Delete", comment: "")
        let image = UIImage(systemName: "trash")

        let action = UIAction(title: title, image: image) { _ in
            self.perform()
        }

        action.attributes = .destructive
        return action
    }

    func swipeAction() -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: nil) { _, _, completion in
            self.perform()
            completion(true)
        }

        action.image = UIImage(systemName: "trash.fill", withConfiguration: Style.swipeActionImageConfiguration)
        action.backgroundColor = .systemPink
        return action
    }
}

extension DuplicateAction {

    func menuAction() -> UIAction {
        let title = NSLocalizedString("Duplicate", comment: "")
        let image = UIImage(systemName: "plus.square.on.square")

        return UIAction(title: title, image: image) { _ in
            self.perform()
        }
    }
}

extension ShareAction {

    func menuAction() -> UIAction {
        let title = NSLocalizedString("Share", comment: "")
        let image = UIImage(systemName: "square.and.arrow.up")

        return UIAction(title: title, image: image) { _ in
            self.perform()
        }
    }

    func swipeAction() -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: nil) { _, _, completion in
            self.perform()
            completion(true)
        }

        action.image = UIImage(systemName: "square.and.arrow.up.fill", withConfiguration: Style.swipeActionImageConfiguration)
        action.backgroundColor = Style.mainTint
        return action
    }
}
