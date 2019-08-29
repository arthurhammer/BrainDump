import UIKit

class SlideAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    let isPresenting: Bool
    let duration: TimeInterval = 0.25

    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using context: UIViewControllerContextTransitioning) {
        guard let presentedView = self.presentedView(in: context),
            let presentedViewController = self.presentedViewController(in: context) else { return }

        let duration = transitionDuration(using: context)
        let finalFrame: CGRect

        if isPresenting {
            finalFrame = context.finalFrame(for: presentedViewController)
            let initialFrame = finalFrame.offsetBy(dx: -finalFrame.width, dy: 0)
            presentedView.frame = initialFrame
            context.containerView.addSubview(presentedView)
        } else {
            finalFrame = presentedView.frame.offsetBy(dx: -presentedView.frame.width, dy: 0)
        }

        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
            presentedView.frame = finalFrame
        }, completion: { _ in
            context.completeTransition(!context.transitionWasCancelled)
        })
    }

    private func presentedView(in context: UIViewControllerContextTransitioning) -> UIView? {
        return isPresenting ? context.view(forKey: .to) : context.view(forKey: .from)
    }

    func presentedViewController(in context: UIViewControllerContextTransitioning) -> UIViewController? {
        return isPresenting ? context.viewController(forKey: .to) : context.viewController(forKey: .from)
    }
}

