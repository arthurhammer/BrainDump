import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var coordinator: Coordinator!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Style.configure(for: window)

        let store = CoreDataStore(name: "BrainDump")

        store.loadStore {
            let settings = Settings()
            let purger = Purger(context: store.viewContext, settings: settings)
            let editorViewController = (self.window!.rootViewController as! UINavigationController).topViewController as! EditorViewController

            self.coordinator = Coordinator(store: store, purger: purger, settings: settings, editorViewController: editorViewController)
        }

        return true
    }
}
