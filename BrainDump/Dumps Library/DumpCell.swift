import UIKit

class DumpCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var expirationLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        expirationLabel.text = nil
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = Style.cellSelectionColor
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        expirationLabel.text = nil
    }
}

// #MARK: - Configuring

extension DumpCell {

    static let dateFormatter = DateModifiedFormatter()
    static let expirationFormatter = TimeRemainingFormatter()

    func configure(with dump: Dump, expirationDate: Date?) {
        let emptyTitle = NSLocalizedString("New Dump", comment: "Default title for an empty dump")
        titleLabel.text = dump.title ?? emptyTitle
        bodyLabel.text = dump.previewText
        dateLabel.text = DumpCell.dateFormatter.string(from: dump.dateModified)

        if let date = expirationDate {
            expirationLabel.text = DumpCell.expirationFormatter.string(from: Date(), to: date)
        } else {
            expirationLabel.text = nil
        }
    }
}
