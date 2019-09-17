import UIKit

protocol SettingsViewControllerDelegate: class {
    func controllerDidFinish(_ controller: SettingsViewController)
}

class SettingsViewController: UITableViewController {

    weak var delegate: SettingsViewControllerDelegate?

    var settings: Settings!

    @IBOutlet private var createNoteAfterSwitch: UISwitch!
    @IBOutlet private var createNoteAfterLabel: UILabel!
    @IBOutlet private var createNoteAfterStepper: TimeUntilStepper!

    @IBOutlet private var deleteNotesAfterSwitch: UISwitch!
    @IBOutlet private var deleteNotesAfterLabel: UILabel!
    @IBOutlet private var deleteNotesAfterStepper: TimeUntilStepper!

    private var hiddenIndexPaths = Set<IndexPath>()
    private lazy var afterTimeFormatter = AfterTimeFormatter()

    // Changing deletion date is potentially destructive. Delay until "done".
    private lazy var modifiedDeleteNotesAfter = settings.deleteNotesAfter

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }

    @IBAction func done() {
        // Save changes now.
        settings.deleteNotesAfter = modifiedDeleteNotesAfter
        delegate?.controllerDidFinish(self)
    }

    @IBAction func stepperChanged() {
        settings.createNoteAfter.value = createNoteAfterStepper.dateValue
        modifiedDeleteNotesAfter.value = deleteNotesAfterStepper.dateValue
        updateLabels()
    }

    @IBAction private func switchChanged() {
        settings.createNoteAfter.isEnabled = createNoteAfterSwitch.isOn
        modifiedDeleteNotesAfter.isEnabled = deleteNotesAfterSwitch.isOn
        updateHiddenCells()
    }

    private func configureViews() {
        createNoteAfterSwitch.isOn = settings.createNoteAfter.isEnabled
        createNoteAfterStepper.dateValues = settings.createNoteAfterOptions
        createNoteAfterStepper.dateValue = settings.createNoteAfter.value

        deleteNotesAfterSwitch.isOn = modifiedDeleteNotesAfter.isEnabled
        deleteNotesAfterStepper.dateValues = settings.deleteNotesAfterOptions
        deleteNotesAfterStepper.dateValue = modifiedDeleteNotesAfter.value

        updateHiddenCells()
        updateLabels()
    }

    private func updateHiddenCells() {
        showIndexPath(IndexPath(row: 1, section: 0), show: settings.createNoteAfter.isEnabled)
        showIndexPath(IndexPath(row: 1, section: 1), show: modifiedDeleteNotesAfter.isEnabled)
    }

    private func updateLabels() {
        createNoteAfterLabel.text = afterTimeFormatter.localizedString(from: createNoteAfterStepper.dateValue)
        deleteNotesAfterLabel.text = afterTimeFormatter.localizedString(from: deleteNotesAfterStepper.dateValue)
    }

    private func showIndexPath(_ indexPath: IndexPath, show: Bool) {
        if show {
            hiddenIndexPaths.remove(indexPath)
        } else {
            hiddenIndexPaths.insert(indexPath)
        }

        // Update cell heights.
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        hiddenIndexPaths.contains(indexPath) ? 0 : UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        indexPath.section > 1
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = Style.cellSelectionColor
    }
}
