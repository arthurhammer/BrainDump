import UIKit

class TransitionController {

    private lazy var libraryTransitionController = SlideTransitionController()

    var libraryInteractionController: SlideInteractor {
        libraryTransitionController.interactionController
    }

    func prepareForSettingsTransition(for presented: UIViewController) {
        if #available(iOS 13.0, *) { }
        else {
            // Workaround for a UIKit bug where the library is erroneously resized when
            // presenting settings full-screen.
            presented.modalPresentationStyle = .custom
        }
    }

    func prepareForLibraryTransition(for presented: UIViewController) {
        libraryTransitionController.prepareTransition(for: presented)
    }
}
