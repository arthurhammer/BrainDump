import UIKit

struct Style {

    static var mainTint: UIColor = .systemIndigo

    static var toolBarBackgroundColor: UIColor {
        // Ideally we'd just use `systemGroupedBackground` but it seems to change
        // shades not only with `userInterfaceStyle` but also based on whether its in
        // a grouped table view or not. Hard-code, so editor and library share the
        // same toolbar color.
        return UIColor {
            ($0.userInterfaceStyle == .light)
                ? .systemGroupedBackground
                : UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.00)
        }
    }

    static let orange = UIColor.systemOrange
    static let red = UIColor.systemPink
}

extension Style {
    static var swipeActionImageConfiguration = UIImage.SymbolConfiguration(textStyle: .title2)
}

extension Style {

    static func configure(for window: UIWindow?) {
        window?.tintColor = Style.mainTint
        UIWindow.appearance().tintColor = Style.mainTint

        UINavigationBar.appearance().shadowImage = UIImage()

        UIToolbar.appearance().tintColor = Style.mainTint
        UIToolbar.appearance().barTintColor = Style.toolBarBackgroundColor
        UIToolbar.appearance().setShadowImage(UIImage(), forToolbarPosition: .any)
        UIToolbar.appearance().isTranslucent = false

        UISwitch.appearance().onTintColor = Style.mainTint
    }
}
