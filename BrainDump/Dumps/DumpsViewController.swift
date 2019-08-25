import UIKit

protocol DumpsViewControllerDelegate: class {
    func controller(_ controller: DumpsViewController, didSelectDump dump: Dump)
    func controllerDidSelectCreateNewDump(_ controller: DumpsViewController)
}

class DumpsViewController: UITableViewController {

    var delegate: DumpsViewControllerDelegate?

    private let cellIdentifier = "Cell"

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var dataSource: DumpsDataSource? {
        didSet { configureDataSource() }
    }

    @IBAction private func done() {
        dismiss(animated: true)
    }

    @IBAction func createNewDump() {
        delegate?.controllerDidSelectCreateNewDump(self)
    }

    @IBAction private func deleteAllDumps() {
        dataSource?.deleteAllDumps()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let dump = dataSource?.dump(at: indexPath.row) else { return }
        delegate?.controller(self, didSelectDump: dump)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.numberOfDumps() ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if let dump = dataSource?.dump(at: indexPath.row) {
            configure(cell: cell, for: dump)
        }
        return cell
    }

    private func configure(cell: UITableViewCell, for dump: Dump) {
        cell.textLabel?.text = dump.text
        cell.detailTextLabel?.text = dateFormatter.string(from: dump.dateModified)
    }

    private func reconfigure(cellAt indexPath: IndexPath, for dump: Dump) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        configure(cell: cell, for: dump)
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let actions = [deleteAction(for: indexPath), shareAction(for: indexPath)]
        return UISwipeActionsConfiguration(actions: actions)
    }

    private func deleteAction(for indexPath: IndexPath) -> UIContextualAction {
        let title = NSLocalizedString("Delete", comment: "")

        return UIContextualAction(style: .destructive, title: title) { [weak self] action, _, completion in
            guard let dataSource = self?.dataSource else {
                completion(false)
                return
            }
            dataSource.deleteDump(at: indexPath.row)
            completion(true)
        }
    }

    private func shareAction(for indexPath: IndexPath) -> UIContextualAction {
        let title = NSLocalizedString("Share", comment: "")

        return UIContextualAction(style: .normal, title: title) { [weak self] action, _, completion in
            let text = self?.dataSource?.dump(at: indexPath.row).text ?? ""
            let controller = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            self?.present(controller, animated: true)
            completion(true)
        }
    }

    private func configureDataSource() {
        dataSource?.dumpsWillChange = tableView.beginUpdates

        dataSource?.dumpDidChange = { [weak self] change in
            self?.tableView.applyChange(change, cellUpdater: { object, indexPath in
                guard let dump = object as? Dump else { return }
                self?.reconfigure(cellAt: indexPath, for: dump)
            })
        }

        dataSource?.dumpsDidChange = tableView.endUpdates

        tableView.reloadData()
    }
}
