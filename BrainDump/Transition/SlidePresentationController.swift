import UIKit

class SlidePresentationController: UIPresentationController {

    var interactionController: SlideInteractor?

    private let widthFraction: CGFloat = 0.85
    private let dimmingOpacity: CGFloat = 0.4
    private let cornerRadius: CGFloat = 0

    private lazy var tapToDismissRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
    private lazy var panToDismissRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan))

    private lazy var dimmingView: UIView = {
        let view = UIView(frame: .zero)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.alpha = 0
        view.backgroundColor = .black
        tapToDismissRecognizer.require(toFail: panToDismissRecognizer)
        view.addGestureRecognizer(tapToDismissRecognizer)
        view.addGestureRecognizer(panToDismissRecognizer)
        return view
    }()

    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, interactor: SlideInteractor?) {
        self.interactionController = interactor
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let container = containerView else { return .zero }

        let size = self.size(forChildContentContainer: presentedViewController, withParentContainerSize: container.frame.size)
        return CGRect(origin: .zero, size: size)
    }

    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        CGSize(width: parentSize.width * widthFraction, height: parentSize.height)
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        let target = frameOfPresentedViewInContainerView
        guard presentedView?.frame != target else { return }
        presentedView?.frame = target
    }

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()

        presentedView?.layer.cornerRadius = cornerRadius
        presentedView?.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        presentedView?.clipsToBounds = true

        dimmingView.frame = containerView?.bounds ?? .zero
        containerView?.addSubview(dimmingView)

        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = self.dimmingOpacity
        }, completion: nil)
    }

    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()

        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0
        }, completion: nil)
    }

    @objc private func didTap(sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }
        presentedViewController.dismiss(animated: true)
    }

    @objc private func didPan(sender: UIPanGestureRecognizer) {
        interactionController?.handlePan(for: sender, transitionType: .dismissal, performTransition: {
            presentedViewController.dismiss(animated: true)
        })
    }
}
