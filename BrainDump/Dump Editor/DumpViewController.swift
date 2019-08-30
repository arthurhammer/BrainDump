import UIKit

protocol DumpViewControllerDelegate: class {
    func controllerDidSelectShowLibrary(_ controller: DumpViewController)
}

class DumpViewController: UIViewController {

    weak var delegate: DumpViewControllerDelegate?

    var dataSource: DumpDataSource? {
        didSet { configureDataSource() }
    }

    @IBOutlet var textView: UITextView?
    @IBOutlet private var toolbar: UIToolbar?

    private lazy var toolbarWrapper = self.toolbar.flatMap(SafeAreaInputAccessoryViewWrapperView.init)
    private let textInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override var inputAccessoryView: UIView? {
        return toolbarWrapper
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        textView?.delegate = self
        textView?.textContainerInset = textInsets
        toolbar?.setShadowImage(UIImage(), forToolbarPosition: .bottom)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
        let text = textView?.text ?? ""
        let controller = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(controller, animated: true)
    }

    @IBAction private func deleteDump() {
        dataSource?.deleteDump()
        textView?.startEditing(animated: true)
    }

    @IBAction func createNewDump() {
        // Create actual new dump only when user starts editing.
        dataSource?.archiveDump()
        textView?.startEditing(animated: true)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey],
            let keyboardHeight = (keyboardFrame as? NSValue)?.cgRectValue.size.height else { return }

        textView?.contentInset.bottom = keyboardHeight
        textView?.scrollIndicatorInsets.bottom = keyboardHeight
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        textView?.contentInset = .zero
        textView?.scrollIndicatorInsets = .zero
    }

    private func showDump() {
        // Avoid setting text view again in response to change handler originating in
        // text view change.
        guard textView?.text != dataSource?.dump?.text else { return }
        textView?.text = dataSource?.dump?.text
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
        textView?.startEditing(animated: true)
    }
}

extension DumpViewController: UITextViewDelegate {

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
