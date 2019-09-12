import UIKit

extension UIViewController {

    /// When using UISearchController a bottom border appears that is unhideable using the
    /// conventional approach (hiding shadow image of the navigation bar).
    /// Overlay a colored view that blends with the rest of the navigation/search bar.
    /// - Warning: This might break in future iOS releases.
    func _hackToHideGoddamnNavigationBarBottomBorder(for searchController: UISearchController) {
        let bar = searchController.searchBar
        let barColor = navigationController?.navigationBar.barTintColor ?? .white

        // Border is outside the search bar, starts at y, not y-1.
        let frame = CGRect(x: 0, y: bar.frame.maxY, width: bar.frame.width, height: 1)
        let border = UIView(frame: frame)
        border.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        border.backgroundColor = barColor
        bar.addSubview(border)

        // If using non translucent bar with the same intended border color, colors will
        // be off since the translucency changes the appearance of the color.
        navigationController?.navigationBar.isTranslucent = false
        // But non-translucency adds lunacy snapping bar behaviour so disable that.
        extendedLayoutIncludesOpaqueBars = true
    }
}

