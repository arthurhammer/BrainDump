import UIKit

struct Style {

    static var mainTint: UIColor {
        if #available(iOS 13, *) {
            return .systemIndigo
       } else {
            return .systemPurple  // iOS 12 purple is iOS 13 indigo.
       }
    }

    static var mainBackgroundColor: UIColor {
        if #available(iOS 13, *) {
            return .systemBackground
        } else {
            return .white
        }
    }

    static var toolBarBackgroundColor: UIColor {
        if #available(iOS 13, *) {
            // Ideally we'd just use `systemGroupedBackground` but it seems to change
            // shades not only with `userInterfaceStyle` but also based on whether its in
            // a grouped table view or not. Hard-code, so editor and library share the
            // same toolbar color.
            return UIColor {
                ($0.userInterfaceStyle == .light)
                    ? .systemGroupedBackground
                    : UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.00)
            }
        } else {
            return .groupTableViewBackground
        }
    }

    static let orange = UIColor.systemOrange
    static let red = UIColor.systemPink
}

extension Style {

    static func configure(for window: UIWindow?) {
        window?.tintColor = Style.mainTint
        UIWindow.appearance().tintColor = Style.mainTint

        UINavigationBar.appearance().tintColor = Style.mainTint
        UINavigationBar.appearance().barTintColor = Style.mainBackgroundColor
        UINavigationBar.appearance().shadowImage = UIImage()

        UIToolbar.appearance().tintColor = Style.mainTint
        UIToolbar.appearance().barTintColor = Style.toolBarBackgroundColor
        UIToolbar.appearance().setShadowImage(UIImage(), forToolbarPosition: .any)
        UIToolbar.appearance().isTranslucent = false

        UISwitch.appearance().onTintColor = Style.mainTint
    }
}
