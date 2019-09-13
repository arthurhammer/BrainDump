import UIKit

class LibrarySectionHeader: UITableViewHeaderFooterView {

    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var actionButton: UIButton!

    override func prepareForReuse() {
        super.prepareForReuse()

        actionButton.allTargets.forEach {
            actionButton.removeTarget($0, action: nil, for: .allEvents)
        }
    }
}

// #MARK: - Configuring

extension LibrarySectionHeader {

    func configure(with type: LibrarySectionType, actionTarget: Any?, action: Selector?) {
        switch type {

        case .pinned:
            imageView.image = #imageLiteral(resourceName: "pin-filled")
            imageView.tintColor = Style.orange
            titleLabel.text = NSLocalizedString("Pinned", comment: "")
            actionButton.isHidden = true

        case .unpinned:
            imageView.image = #imageLiteral(resourceName: "bulb-filled")
            imageView.tintColor = Style.mainTint
            titleLabel.text = NSLocalizedString("My Thoughts", comment: "")
            actionButton.isHidden = false

            if let action = action {
                actionButton.addTarget(actionTarget, action: action, for: .touchUpInside)
            }
        }

        titleLabel.text = titleLabel.text?.uppercased()
    }
}
