import UIKit

class DumpCell: UITableViewCell {

    let selectionColor = UIColor(red: 0.94, green: 0.94, blue: 0.97, alpha: 1.00)

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

        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = selectionColor
        isPinned = false
        isPinnedImageView.tintColor = .lightGray
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        isPinned = false
    }
}
