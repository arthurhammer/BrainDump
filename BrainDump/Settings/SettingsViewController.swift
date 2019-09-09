import UIKit

protocol SettingsViewControllerDelegate: class {
    func controllerDidFinish(_ controller: SettingsViewController)
}

class SettingsViewController: UITableViewController {

    weak var delegate: SettingsViewControllerDelegate?

    let settings = UserDefaults.standard

    @IBOutlet private var createNewDumpAfterSwitch: UISwitch!
    @IBOutlet private var createNewDumpAfterLabel: UILabel!
    @IBOutlet private var createNewDumpAfterStepper: TimeUntilStepper!

    @IBOutlet private var deleteOldDumpsAfterSwitch: UISwitch!
    @IBOutlet private var deleteOldDumpsAfterLabel: UILabel!
    @IBOutlet private var deleteOldDumpsAfterStepper: TimeUntilStepper!

    private var hiddenIndexPaths = Set<IndexPath>()
    private lazy var afterTimeFormatter = AfterTimeFormatter()

    // Changing deletion date is potentially destructive. Delay until "done".
    private lazy var modifiedIsDeleteOldDumpsAfterEnabled = settings.isDeleteOldDumpsAfterEnabled
    private lazy var modifiedDeleteOldDumpsAfter = settings.deleteOldDumpsAfter

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }

    @IBAction func done() {
        // Save changes now.
        settings.isDeleteOldDumpsAfterEnabled = modifiedIsDeleteOldDumpsAfterEnabled
        settings.deleteOldDumpsAfter = modifiedDeleteOldDumpsAfter
        delegate?.controllerDidFinish(self)
    }

    @IBAction func stepperChanged() {
        settings.createNewDumpAfter = createNewDumpAfterStepper.dateValue
        modifiedDeleteOldDumpsAfter = deleteOldDumpsAfterStepper.dateValue
        updateLabels()
    }

    @IBAction private func switchChanged() {
        settings.isCreateNewDumpAfterEnabled = createNewDumpAfterSwitch.isOn
        modifiedIsDeleteOldDumpsAfterEnabled = deleteOldDumpsAfterSwitch.isOn
        updateHiddenCells()
    }

    private func configureViews() {
        createNewDumpAfterSwitch.isOn = settings.isCreateNewDumpAfterEnabled
        createNewDumpAfterStepper.dateValues = settings.createNewDumpAfterOptions
        createNewDumpAfterStepper.dateValue = settings.createNewDumpAfter

        deleteOldDumpsAfterSwitch.isOn = modifiedIsDeleteOldDumpsAfterEnabled
        deleteOldDumpsAfterStepper.dateValues = settings.deleteOldDumpsAfterOptions
        deleteOldDumpsAfterStepper.dateValue = modifiedDeleteOldDumpsAfter

        updateHiddenCells()
        updateLabels()
    }

    private func updateHiddenCells() {
        showIndexPath(IndexPath(row: 1, section: 0), show: settings.isCreateNewDumpAfterEnabled)
        showIndexPath(IndexPath(row: 1, section: 1), show: modifiedIsDeleteOldDumpsAfterEnabled)
    }

    private func updateLabels() {
        createNewDumpAfterLabel.text = afterTimeFormatter.localizedPhrasedString(from: createNewDumpAfterStepper.dateValue)
        deleteOldDumpsAfterLabel.text = afterTimeFormatter.localizedPhrasedString(from: deleteOldDumpsAfterStepper.dateValue)
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
