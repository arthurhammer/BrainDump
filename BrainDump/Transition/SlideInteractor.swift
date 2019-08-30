import UIKit

/// Handles interactive pan gestures, initiates the interactive transition if necessary
/// and drives the progress of the animator's animation (coordinated by `SlideTransitionController`).
class SlideInteractor: UIPercentDrivenInteractiveTransition {

    let thresholdProgress: CGFloat = 0.1
    let thresholdVelocity: CGFloat = 700

    private var didTransition: Bool = false

    func handlePan(for gesture: UIPanGestureRecognizer, transitionType: TransitionType, performTransition: () -> ()) {
        let progress = gesture.progress(forDirection: transitionType)
        let velocity = gesture.progressVelocity(forDirection: transitionType).x

        switch gesture.state {

        // Began by moving right, start presentation (analogous for dismissal).
        case .began where velocity > 0:
            wantsInteractiveStart = true
            didTransition = true
            performTransition()

        // Began by moving left, don't start presentation.
        case .began:
            wantsInteractiveStart = true
            didTransition = false

        // When moving right after moving left initially, start presentation now.
        case .changed where velocity > 0 && !didTransition:
            didTransition = true
            // Use current location as progress reference.
            gesture.setTranslation(.zero, in: gesture.view)
            performTransition()

        // Update progress after starting presentation.
        case .changed:
            update(progress)

        case .cancelled:
            wantsInteractiveStart = false
            cancel()

        // Continue or revert animation on release.
        case .ended where didTransition:
            wantsInteractiveStart = false

            let hasSufficientVelocity = velocity >= thresholdVelocity
            let hasSufficientDistanceAndCorrectDirection = (progress >= thresholdProgress) && (velocity > 0)

            if hasSufficientVelocity || hasSufficientDistanceAndCorrectDirection {
                finish()
            } else {
                cancel()
            }

        default:
            didTransition = false
            wantsInteractiveStart = false
        }
    }
}

private extension UIPanGestureRecognizer {

    /// The fraction of the view's width the pan has moved in the direction of the
    /// transition.
    func progress(forDirection direction: TransitionType) -> CGFloat {
        guard let view = view else { return .zero }

        let fraction = translation(in: view).x / view.bounds.width

        switch direction {
        case .presentation: return min(max(fraction, 0), 1)
        case .dismissal: return -max(min(fraction, 0), -1)
        }
    }

    /// The absolute velocity value with a positive sign if it is moving in the direction
    /// of the transition (right for presentation, left for dismissal), negative if not.
    func progressVelocity(forDirection direction: TransitionType) -> CGPoint {
        let velocity = self.velocity(in: view)

        switch direction {
        case .presentation: return velocity
        case .dismissal: return CGPoint(x: -velocity.x, y: velocity.y)
        }
    }
}
