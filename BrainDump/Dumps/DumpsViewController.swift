import UIKit

protocol DumpsViewControllerDelegate: class {
    func controller(_ controller: DumpsViewController, didSelectDump dump: Dump)
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

    private func configureDataSource() {
        dataSource?.dumpDidChange = { [weak self] change in
            self?.tableView.applyChange(change, cellUpdater: { object, indexPath in
                guard let dump = object as? Dump else { return }
                self?.reconfigure(cellAt: indexPath, for: dump)
            })
        }

        tableView.reloadData()
    }
}
