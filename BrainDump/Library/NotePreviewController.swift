import UIKit

class NotePreviewController: UIViewController {

    var note: Note? {
        didSet { textView.text = note?.text }
    }

    let textView = EditorTextView(frame: .zero, textContainer: nil)

    init(note: Note) {
        self.note = note
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.frame = view.bounds
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textView.text = note?.text
        view.addSubview(textView)
    }
}
