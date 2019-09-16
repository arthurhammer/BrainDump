import UIKit

// Adapted from: https://github.com/stockx/SafeAreaInputAccessoryViewWrapperView
// MIT License: Copyright (c) 2017 Jeff Burt <jburt1992@gmail.com>

/**
 SafeAreaInputAccessoryViewWrapperView is useful for wrapping a view to be used
 as an inputAccessoryView. Without this, setting the view as an
 inputAccessoryView will ignore safe area layouts. For example, the Home screen
 indicator on iPhone X will battle for the same spot. This class ensures that
 the view respects safe area layouts and does not cover up system UI elements
 such as the Home screen indicator on iPhone X.
 */
public class SafeAreaInputAccessoryViewWrapperView: UIView {

    public init(for view: UIView) {
        super.init(frame: .zero)

        addSubview(view)

        // Allow 'self' to be sized based on autolayout constraints. Without
        // this, the frame would have to be set manually.
        autoresizingMask = .flexibleHeight
        view.translatesAutoresizingMaskIntoConstraints = false

        defer {
            view.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
            view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override var intrinsicContentSize: CGSize {
        // Allow 'self' to be sized based on autolayout constraints. Without
        // this, the frame would have to be set manually.
        .zero
    }
}
