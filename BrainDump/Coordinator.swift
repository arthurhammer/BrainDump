import UIKit

class Coordinator {

    let store: CoreDataStore
    let settings: Settings
    let purger: DumpsPurger

    let editorViewController: EditorViewController

    lazy var libraryContainer: UINavigationController = {
        let storyboardId = "Library"
        guard let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: storyboardId) as? UINavigationController else { fatalError("Wrong controller id or type.") }
        return controller
    }()

    lazy var libraryViewController: DumpsViewController = {
        guard let controller = libraryContainer.viewControllers.first as? DumpsViewController else { fatalError("Wrong root controller.") }
        return controller
    }()

    lazy var transitionController = SlideTransitionController()

    init(store: CoreDataStore, purger: DumpsPurger, settings: Settings, editorViewController: EditorViewController) {
        self.store = store
        self.purger = purger
        self.settings = settings

        self.editorViewController = editorViewController
        self.editorViewController.delegate = self
        self.editorViewController.dataSource = EditorDataSource(store: store, settings: settings)
        
        configureSlideToLibraryGesture()
    }
}

private extension Coordinator {

    func showLibrary() {
        if libraryViewController.dataSource == nil {
            libraryViewController.dataSource = DumpsDataSource(store: store, settings: settings)
        }

        libraryViewController.delegate = self
        libraryViewController.selectedDump = editorViewController.dataSource?.dump

        transitionController.prepareTransition(for: libraryContainer)
        editorViewController.view.endEditing(true)
        editorViewController.present(libraryContainer, animated: true)
    }

    func hideLibrary() {
        editorViewController.dismiss(animated: true)
    }

    func showSettings() {
        guard let settingsContainer = UIStoryboard(name: "Settings", bundle: nil).instantiateInitialViewController() as? UINavigationController,
            let settingsViewController = settingsContainer.topViewController as? SettingsViewController else { fatalError("Wrong storyboard id or controller type.") }

        settingsContainer.modalPresentationStyle = .custom   // TODO
        settingsViewController.delegate = self
        settingsViewController.settings = settings
        libraryViewController.present(settingsContainer, animated: true)
    }

    func configureSlideToLibraryGesture() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleSlideToLibraryPan(sender:)))
        editorViewController.editor?.panGestureRecognizer.shouldRequireFailure(of: panRecognizer)
        editorViewController.view.addGestureRecognizer(panRecognizer)
    }

    @objc func handleSlideToLibraryPan(sender: UIPanGestureRecognizer) {
        transitionController.interactionController.handlePan(for: sender, transitionType: .presentation, performTransition: showLibrary)
    }
}

extension Coordinator: EditorViewControllerDelegate {

    func controllerDidSelectShowLibrary(_ controller: EditorViewController) {
        showLibrary()
    }
}

extension Coordinator: DumpsViewControllerDelegate {

    func controllerDidFinish(_ controller: DumpsViewController) {
        hideLibrary()
    }

    func controllerDidSelectShowSettings(_ controller: DumpsViewController) {
        showSettings()
    }

    func controller(_ controller: DumpsViewController, didSelectDump dump: Dump) {
        hideLibrary()
        editorViewController.dataSource?.dump = dump
    }

    func controllerDidSelectCreateNewDump(_ controller: DumpsViewController) {
        hideLibrary()
        editorViewController.createNewDump()
    }
}

extension Coordinator: SettingsViewControllerDelegate {

    func controllerDidFinish(_ controller: SettingsViewController) {
        libraryContainer.dismiss(animated: true)
    }
}
