import UIKit

class DumpViewController: UIViewController {

    var dataSource: DumpDataSource? {
        didSet {
            textView?.text = dataSource?.currentDump?.text
            textView?.startEditing(animated: false)
        }
    }

    @IBOutlet private weak var textView: UITextView?
    @IBOutlet private weak var toolbar: UIToolbar?

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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // In some cases, inputAccessoryView vanishes, e.g. when showing full screen share
        // sheet action.
        becomeFirstResponder()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = (segue.destination as? UINavigationController)?.topViewController as? DumpsViewController {
            prepareForDumpsSegue(with: controller)
        }
    }

    private func prepareForDumpsSegue(with destination: DumpsViewController) {
        destination.delegate = self
        destination.dataSource = dataSource?._todoDumpsDataSource()
    }

    @IBAction private func shareDump() {
        let text = textView?.text ?? ""
        let controller = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(controller, animated: true)
    }

    @IBAction private func deleteDump() {
        dataSource?.deleteCurrentDump()
        createNewDump()
    }

    @IBAction private func createNewDump() {
        dataSource?.createNewCurrentDump()
        textView?.text = dataSource?.currentDump?.text
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey],
            let keyboardHeight = (keyboardFrame as? NSValue)?.cgRectValue.size.height else { return }

        textView?.contentInset.bottom = textInsets.bottom + keyboardHeight
        textView?.scrollIndicatorInsets.bottom = keyboardHeight
    }

    @objc private func keyboardDidHide(notification: NSNotification) {
        textView?.contentInset = .zero
        textView?.scrollIndicatorInsets = .zero
    }
}

extension DumpViewController: UITextViewDelegate {

    func textViewDidEndEditing(_ textView: UITextView) {
        dataSource?.save()
    }

    func textViewDidChange(_ textView: UITextView) {
        dataSource?.currentDump?.text = textView.text
    }
}

extension DumpViewController: DumpsViewControllerDelegate {
    func controller(_ controller: DumpsViewController, didSelectDump dump: Dump) {
        dismiss(animated: true)
        dataSource?.currentDump = dump
        textView?.text = dump.text
    }
}
