import UIKit

protocol SettingsViewControllerDelegate: class {
    func controllerDidFinish(_ controller: SettingsViewController)
}

class SettingsViewController: UITableViewController {

    weak var delegate: SettingsViewControllerDelegate?

    var settings: Settings!

    @IBOutlet private var createDumpAfterSwitch: UISwitch!
    @IBOutlet private var createDumpAfterLabel: UILabel!
    @IBOutlet private var createDumpAfterStepper: TimeUntilStepper!

    @IBOutlet private var deleteDumpsAfterSwitch: UISwitch!
    @IBOutlet private var deleteDumpsAfterLabel: UILabel!
    @IBOutlet private var deleteDumpsAfterStepper: TimeUntilStepper!

    private var hiddenIndexPaths = Set<IndexPath>()
    private lazy var afterTimeFormatter = AfterTimeFormatter()

    // Changing deletion date is potentially destructive. Delay until "done".
    private lazy var modifiedDeleteDumpsAfter = settings.deleteDumpsAfter

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }

    @IBAction func done() {
        // Save changes now.
        settings.deleteDumpsAfter = modifiedDeleteDumpsAfter
        delegate?.controllerDidFinish(self)
    }

    @IBAction func stepperChanged() {
        settings.createDumpAfter.value = createDumpAfterStepper.dateValue
        modifiedDeleteDumpsAfter.value = deleteDumpsAfterStepper.dateValue
        updateLabels()
    }

    @IBAction private func switchChanged() {
        settings.createDumpAfter.isEnabled = createDumpAfterSwitch.isOn
        modifiedDeleteDumpsAfter.isEnabled = deleteDumpsAfterSwitch.isOn
        updateHiddenCells()
    }

    private func configureViews() {
        createDumpAfterSwitch.isOn = settings.createDumpAfter.isEnabled
        createDumpAfterStepper.dateValues = settings.createDumpAfterOptions
        createDumpAfterStepper.dateValue = settings.createDumpAfter.value

        deleteDumpsAfterSwitch.isOn = modifiedDeleteDumpsAfter.isEnabled
        deleteDumpsAfterStepper.dateValues = settings.deleteDumpsAfterOptions
        deleteDumpsAfterStepper.dateValue = modifiedDeleteDumpsAfter.value

        updateHiddenCells()
        updateLabels()
    }

    private func updateHiddenCells() {
        showIndexPath(IndexPath(row: 1, section: 0), show: settings.createDumpAfter.isEnabled)
        showIndexPath(IndexPath(row: 1, section: 1), show: modifiedDeleteDumpsAfter.isEnabled)
    }

    private func updateLabels() {
        createDumpAfterLabel.text = afterTimeFormatter.localizedPhrasedString(from: createDumpAfterStepper.dateValue)
        deleteDumpsAfterLabel.text = afterTimeFormatter.localizedPhrasedString(from: deleteDumpsAfterStepper.dateValue)
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
        return hiddenIndexPaths.contains(indexPath) ? 0 : UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section > 1
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = Style.cellSelectionColor
    }
}
