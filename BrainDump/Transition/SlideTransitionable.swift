/// Optional protocol for participating view controllers (presented, presenting, source)
/// to be notified about the life cycle of the slide transition.
protocol SlideTransitionable {
    func presentationTransitionWillBegin()
    func presentationTransitionDidEnd(completed: Bool)
    func dismissalTransitionWillBegin()
    func dismissalTransitionDidEnd(completed: Bool)
}

extension SlideTransitionable {
    func presentationTransitionWillBegin() {}
    func presentationTransitionDidEnd(completed: Bool) {}
    func dismissalTransitionWillBegin() {}
    func dismissalTransitionDidEnd(completed: Bool) {}
}
