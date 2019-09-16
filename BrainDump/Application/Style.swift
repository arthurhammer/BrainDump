import UIKit

struct Style {
    static let mainTint = Style.purple

    static let mainBackgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1.00) 
    static let cellSelectionColor =  UIColor(red: 0.85, green: 0.85, blue: 0.87, alpha: 1.00)

    static let purple = UIColor(red: 0.35, green: 0.36, blue: 0.83, alpha: 1.00)
    static let orange = UIColor(red: 1.00, green: 0.58, blue: 0.00, alpha: 1.00)
    static let red = UIColor(red: 1.00, green: 0.19, blue: 0.41, alpha: 1.00)
}

extension Style {

    static func configure(for window: UIWindow?) {
        window?.tintColor = Style.mainTint
        UIWindow.appearance().tintColor = Style.mainTint

        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().tintColor = Style.mainTint

        UIToolbar.appearance().setShadowImage(UIImage(), forToolbarPosition: .any)
        UIToolbar.appearance().tintColor = Style.mainTint
        UIToolbar.appearance().barTintColor = Style.mainBackgroundColor
        UIToolbar.appearance().isTranslucent = false

        UITableView.appearance().backgroundColor = Style.mainBackgroundColor
        UISwitch.appearance().onTintColor = Style.mainTint
    }
}
