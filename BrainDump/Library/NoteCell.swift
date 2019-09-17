import UIKit

class NoteCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var expirationLabel: UILabel!
}

// MARK: - Configuring

extension NoteCell {

    static let dateFormatter = DateModifiedFormatter()
    static let expirationFormatter = TimeRemainingFormatter()

    func configure(with note: Note, expirationDate: Date?) {
        let emptyTitle = NSLocalizedString("New Thought", comment: "Default title for an empty note")
        titleLabel.text = note.title ?? emptyTitle
        bodyLabel.text = note.previewText
        dateLabel.text = NoteCell.dateFormatter.string(from: note.dateModified)

        if let date = expirationDate {
            expirationLabel.text = NoteCell.expirationFormatter.string(from: Date(), to: date)
        } else {
            expirationLabel.text = nil
        }
    }
}
