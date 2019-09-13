import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var coordinator: Coordinator!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureAppeareance()

        let store = CoreDataStore(name: "BrainDump")

        store.loadStore {
            let settings = Settings()
            let purger = Purger(context: store.viewContext, settings: settings)
            let editorViewController = (self.window!.rootViewController as! UINavigationController).topViewController as! EditorViewController

            self.coordinator = Coordinator(store: store, purger: purger, settings: settings, editorViewController: editorViewController)
        }

        return true
    }

    private func configureAppeareance() {
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
