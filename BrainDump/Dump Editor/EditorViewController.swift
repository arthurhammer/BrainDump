import UIKit

protocol EditorViewControllerDelegate: class {
    func controllerDidSelectShowLibrary(_ controller: EditorViewController)
}

class EditorViewController: UIViewController {

    weak var delegate: EditorViewControllerDelegate?

    var dataSource: EditorDataSource? {
        didSet { configureDataSource() }
    }

    @IBOutlet var editor: EditorTextView?
    @IBOutlet private var toolbar: UIToolbar?

    private lazy var toolbarWrapper = self.toolbar.flatMap(SafeAreaInputAccessoryViewWrapperView.init)

    override var canBecomeFirstResponder: Bool {
        // No inputAccessoryView when presenting.
        return presentedViewController == nil
    }

    override var inputAccessoryView: UIView? {
        return toolbarWrapper
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        editor?.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // In some cases, inputAccessoryView vanishes, e.g. when showing full screen share
        // sheet action.
        becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dataSource?.save()
    }

    @IBAction private func showLibrary() {
        delegate?.controllerDidSelectShowLibrary(self)
    }

    @IBAction private func shareDump() {
        let text = editor?.text ?? ""
        let controller = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(controller, animated: true)
    }

    @IBAction private func deleteDump() {
        dataSource?.deleteDump()
        editor?.startEditing(animated: true)
    }

    @IBAction func createNewDump() {
        // Create actual new dump only when user starts editing.
        dataSource?.archiveDump()
        editor?.startEditing(animated: true)
    }

    private func showDump() {
        // Avoid setting text view again in response to change handler originating in
        // text view change.
        guard editor?.text != dataSource?.dump?.text else { return }
        editor?.text = dataSource?.dump?.text
    }

    private func updateDump(withText text: String?) {
        if dataSource?.dump == nil, text != nil, text != "" {
            // Create actual new dump.
            dataSource?.createNewDump(withText: text)
        } else {
            dataSource?.dump?.text = text
            dataSource?.dump?.dateModified = Date()
        }
    }

    private func configureDataSource() {
        dataSource?.dumpDidUpdate = { [weak self] in
            self?.showDump()
        }

        showDump()
        editor?.startEditing(animated: true)
    }
}

extension EditorViewController: UITextViewDelegate {

    func textViewDidEndEditing(_ textView: UITextView) {
        // Avoid changing `dateModified` if no changes happened. In `textViewDidChange`,
        // we accept any change though as the user might paste identical text which counts
        // as change.
        if textView.text != dataSource?.dump?.text {
            updateDump(withText: textView.text)
        }

        dataSource?.save()
    }

    func textViewDidChange(_ textView: UITextView) {
        updateDump(withText: textView.text)
    }
}

// #MARK: - Micromanaging `inputAccessoryView`

// For the input accessory view to show, the controller needs to be first responder.
// UIKit automatically manages the input accessory view/first responder status during
// default transitions but fails for custom interactive transitions. Specifically when
// cancelling an interactive dismissal, the accessory re-appears where it shouldn't.

extension EditorViewController: SlideTransitionable {

    func presentationTransitionWillBegin() {
        resignFirstResponder()
    }

    func presentationTransitionDidEnd(completed: Bool) {
        // Delay because `presentedViewController` is not updated until after this returns.
        DispatchQueue.main.async {
            self.becomeFirstResponder(!completed)
        }
    }

    func dismissalTransitionDidEnd(completed: Bool) {
        DispatchQueue.main.async {
            // If editor/keyboard is active, don't steal (this happens when hitting
            // "create new dump" in the library).
            let editorEditing = self.editor?.isFirstResponder ?? false
            self.becomeFirstResponder(completed && !editorEditing)
        }
    }
}
