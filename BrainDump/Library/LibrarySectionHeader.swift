import UIKit

class LibrarySectionHeader: UITableViewHeaderFooterView {

    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
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

    func configure(with type: LibrarySectionType, numberOfItems: Int, actionTarget: Any?, action: Selector?) {
        switch type {

        case .pinned:
            imageView.image = #imageLiteral(resourceName: "pin-filled")
            imageView.tintColor = Style.orange
            titleLabel.text = NSLocalizedString("Pinned", comment: "")
            // Alpha instead if hiding to take the button into account when sizing the
            // header. Otherwise, the header has the wrong size in some case when reloading.
            actionButton.alpha = 0

        case .unpinned:
            imageView.image = #imageLiteral(resourceName: "bulb-filled")
            imageView.tintColor = Style.mainTint
            titleLabel.text = NSLocalizedString("My Thoughts", comment: "")
            actionButton.alpha = 1

            if let action = action {
                actionButton.addTarget(actionTarget, action: action, for: .touchUpInside)
            }
        }

        titleLabel.text = titleLabel.text?.uppercased()
        detailLabel.text = NumberFormatter().string(from: numberOfItems as NSNumber)

        actionButton.backgroundColor = Style.mainTint.withAlphaComponent(0.1)
        actionButton.layer.cornerRadius = 12
    }
}
