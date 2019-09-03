import UIKit

/// A repeating timer that stops when the application enters the background and resumes
/// when it enters the foreground again.
class BackgroundPausingTimer {

    var action: (() -> ())
    let interval: TimeInterval
    var tolerance: TimeInterval {
        didSet { timer?.tolerance = tolerance }
    }

    private var timer: Timer?
    private var lastAction = Date.distantPast
    /// Whether the timer was stopped explicitly and not due to background events.
    private var isStopped = false

    /// The timer is running on initialization. The action is executed once initially.
    init(interval: TimeInterval, tolerance: TimeInterval, action: @escaping () -> ()) {
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
        isStopped = false
        performStart()
    }

    func stop() {
        isStopped = true
        performStop()
    }

    private func performAction() {
        lastAction = Date()
        action()
    }

    @objc private func performStart() {
        guard !isStopped,
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
        NotificationCenter.default.addObserver(self, selector: #selector(performStop), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(performStart), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
}
