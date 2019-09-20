import UIKit

class TransitionController {

    private lazy var libraryTransitionController = SlideTransitionController()

    var libraryInteractionController: SlideInteractor {
        libraryTransitionController.interactionController
    }

    func prepareForLibraryTransition(for presented: UIViewController) {
        libraryTransitionController.prepareTransition(for: presented)
    }
}
