import UIKit

class LibrarySectionHeader: UITableViewHeaderFooterView {

    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

// #MARK: - Configuring

extension LibrarySectionHeader {

    func configure(with type: LibrarySectionType) {
        switch type {
        case .pinned:
            imageView.image = #imageLiteral(resourceName: "pin-filled")
            imageView.tintColor = Style.orange
            titleLabel.text = NSLocalizedString("Pinned", comment: "")
        case .unpinned:
            imageView.image = #imageLiteral(resourceName: "bulb-filled")
            imageView.tintColor = Style.mainTint
            titleLabel.text = NSLocalizedString("My Thoughts", comment: "")
        }

        titleLabel.text = titleLabel.text?.uppercased()
    }
}
