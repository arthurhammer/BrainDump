import UIKit

/// A repeating timer that stops when the application enters the background and resumes
/// when it enters the foreground again.
class BackgroundPausingTimer {

    var action: (() -> ())
    let interval: TimeInterval
    var tolerance: TimeInterval {
        didSet { timer?.tolerance = tolerance }
    }

    private let center: NotificationCenter
    private var timer: Timer?
    private var lastAction = Date.distantPast
    private var isStoppedExplicitly = false

    /// The timer is running on initialization. The action is executed once initially.
    init(interval: TimeInterval, tolerance: TimeInterval, center: NotificationCenter = .default, action: @escaping () -> ()) {
        self.center = center
        self.interval = interval
        self.tolerance = tolerance
        self.action = action

        subscribeToNotifications()
        start()
    }

    deinit {
        timer?.invalidate()
    }

    func start() {
        isStoppedExplicitly = false
        performStart()
    }

    func stop() {
        isStoppedExplicitly = true
        performStop()
    }

    private func performAction() {
        lastAction = Date()
        action()
    }

    @objc private func performStart() {
        guard !isStoppedExplicitly,
            timer == nil else { return }

        if lastAction.addingTimeInterval(interval) <= Date() {
            performAction()
        }

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.performAction()
        }

        timer?.tolerance = tolerance
    }

    @objc private func performStop() {
        timer?.invalidate()
        timer = nil
    }

    private func subscribeToNotifications() {
        center.addObserver(self, selector: #selector(performStop), name: UIApplication.didEnterBackgroundNotification, object: nil)
        center.addObserver(self, selector: #selector(performStart), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
}
