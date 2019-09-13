import UIKit

class DumpCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var expirationLabel: UILabel!
    @IBOutlet var isPinnedImageView: UIImageView!

    var isPinned: Bool = false {
        didSet {
            isPinnedImageView.isHidden = !isPinned
            expirationLabel.isHidden = isPinned
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        isPinned = false
        isPinnedImageView.tintColor = .lightGray
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = Style.cellSelectionColor
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        isPinned = false
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
        isPinned = dump.isPinned

        if let date = expirationDate {
            expirationLabel.text = DumpCell.expirationFormatter.string(from: Date(), to: date)
        } else {
            expirationLabel.text = nil
        }
    }
}
