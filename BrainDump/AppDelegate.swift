import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private var coordinator: Coordinator!
    private var store: CoreDataStore!
    private var purger: DumpsPurger?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureAppeareance()

        store = CoreDataStore(name: "BrainDump")

        store.loadStore {
            let editorViewController = (self.window!.rootViewController as! UINavigationController).topViewController as! EditorViewController
            self.coordinator = Coordinator(store: self.store, editorViewController: editorViewController)
            self.purger = DumpsPurger(context: self.store.viewContext)
        }

        return true
    }

    private func configureAppeareance() {
        let cellSelectionColor = UIColor(red: 0.94, green: 0.94, blue: 0.97, alpha: 1.00)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().barTintColor = .white
        UITableViewCell.appearance().selectedBackgroundView = UIView()
        UITableViewCell.appearance().selectedBackgroundView?.backgroundColor = cellSelectionColor
    }
}
