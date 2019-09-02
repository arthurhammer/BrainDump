import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private var coordinator: Coordinator!
    private var store: CoreDataStore!
    private var purger: DumpsPurger?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UserDefaults.standard.createNewDumpAfter = 30 * 60
        UserDefaults.standard.deleteArchivedDumpsAfter = 24 * 60 * 60

        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().barTintColor = .white

        store = CoreDataStore(name: "BrainDump")

        store.loadStore {
            let editorViewController = (self.window!.rootViewController as! UINavigationController).topViewController as! EditorViewController
            self.coordinator = Coordinator(store: self.store, editorViewController: editorViewController)
            self.purger = DumpsPurger(context: self.store.viewContext)
        }

        return true
    }
}
