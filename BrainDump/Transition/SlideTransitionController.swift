import UIKit

enum TransitionType {
    case presentation
    case dismissal
}

/// The transition delegate for the presented view controller. Provides the top-level
/// transition objects (presentation, animation, interaction controller).
class SlideTransitionController: NSObject, UIViewControllerTransitioningDelegate {

    // Mutated from both the the presenting controller or its owner (owning the 
    // presentation gesture) and the presentation controller (owning the dismiss gesture).
    private(set) lazy var interactionController: SlideInteractor = {
        let interactor = SlideInteractor()
        interactor.wantsInteractiveStart = false
        return interactor
    }()

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        SlidePresentationController(presentedViewController: presented, presenting: presenting, interactor: interactionController)
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        SlideAnimator(type: .presentation)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        SlideAnimator(type: .dismissal)
    }

    func interactionControllerForPresentation(using _animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // By some magic, when returning a `UIPercentDrivenInteractiveTransition` here, it
        // will drive the animator returned in `animationController(forPresented:presenting:source:)`.
        interactionController.wantsInteractiveStart ? interactionController : nil
    }

    func interactionControllerForDismissal(using _animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        interactionController.wantsInteractiveStart ? interactionController : nil
    }
}

extension SlideTransitionController {

    func prepareTransition(for presented: UIViewController) {
        presented.transitioningDelegate = self
        presented.modalPresentationStyle = .custom
        presented.modalPresentationCapturesStatusBarAppearance = true
    }
}
