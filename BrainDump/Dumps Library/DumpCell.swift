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
