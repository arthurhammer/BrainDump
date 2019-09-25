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
        true
    }

    override var inputAccessoryView: UIView? {
        toolbarWrapper
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        editor?.delegate = self
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

    func setNote(_ note: Note?) {
        guard note != dataSource?.note else { return }
        editor?.scrollToTop(animated: false)
        dataSource?.note = note
    }

    func createNewNote(with text: String?) {
        editor?.scrollToTop(animated: false)

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
