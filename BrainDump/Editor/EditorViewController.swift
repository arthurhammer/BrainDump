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
        presentedViewController == nil
    }

    override var inputAccessoryView: UIView? {
        toolbarWrapper
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        editor?.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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

    @IBAction private func shareNote() {
        let text = editor?.text ?? ""
        let controller = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(controller, animated: true)
    }

    @IBAction private func deleteNote() {
        dataSource?.deleteNote()
        editor?.startEditing(animated: true)
    }

    @IBAction func createNewNote() {
        createNewNote(with: nil)
    }

    func createNewNote(with text: String?) {
        if let text = text?.trimmedOrNil {
            dataSource?.createNewNote(with: text)
        } else {
            // Create actual new note only when user starts editing.
            dataSource?.archiveNote()
        }
        editor?.startEditing(animated: true)
    }

    private func showNote() {
        // Avoid setting text view again in response to change handler originating in
        // text view change.
        guard editor?.text != dataSource?.note?.text else { return }
        editor?.text = dataSource?.note?.text
    }

    private func updateNote(with text: String?) {
        if dataSource?.note == nil, text != nil, text != "" {
            // Create actual new note.
            dataSource?.createNewNote(with: text)
        } else {
            dataSource?.note?.text = text
            dataSource?.note?.dateModified = Date()
        }
    }

    private func configureDataSource() {
        dataSource?.noteDidUpdate = { [weak self] in
            self?.showNote()
        }

        showNote()
        editor?.startEditing(animated: true)
    }
}

extension EditorViewController: UITextViewDelegate {

    func textViewDidEndEditing(_ textView: UITextView) {
        // Avoid changing `dateModified` if no changes happened. In `textViewDidChange`,
        // we accept any change though as the user might paste identical text which counts
        // as change.
        if textView.text != dataSource?.note?.text {
            updateNote(with: textView.text)
        }

        dataSource?.save()
    }

    func textViewDidChange(_ textView: UITextView) {
        updateNote(with: textView.text)
    }
}

// MARK: - Micromanaging `inputAccessoryView`

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
            // "create new note" in the library).
            let editorEditing = self.editor?.isFirstResponder ?? false
            self.becomeFirstResponder(completed && !editorEditing)
        }
    }
}
