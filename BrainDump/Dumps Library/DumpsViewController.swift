import UIKit

protocol DumpsViewControllerDelegate: class {
    func controllerDidFinish(_ controller: DumpsViewController)
    func controllerDidSelectShowSettings(_ controller: DumpsViewController)
    func controller(_ controller: DumpsViewController, didSelectDump dump: Dump)
    func controllerDidSelectCreateNewDump(_ controller: DumpsViewController)
}

class DumpsViewController: UITableViewController {

    weak var delegate: DumpsViewControllerDelegate?

    var dataSource: DumpsDataSource? {
        didSet { configureDataSource() }
    }

    var selectedDump: Dump?  {
        didSet { selectDump(selectedDump) }
    }

    private lazy var dateFormatter = DateModifiedFormatter()
    private lazy var expirationFormatter = TimeRemainingFormatter()
    private lazy var updateLabelsTimer = BackgroundPausingTimer(interval: 60, tolerance: 15) { [weak self] in
        self?.reconfigureVisibleCells()
    }

    private let pinActionColor = UIColor(red: 0.42, green: 0.53, blue: 0.93, alpha: 1.00)
    private let sectionSeparatorColor = UIColor(red: 0.94, green: 0.94, blue: 0.97, alpha: 1.00)
    private let sectionHeaderHeight: CGFloat = 5
    private let cellIdentifier = "Cell"

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLabelsTimer.start()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateLabelsTimer.stop()
        tableView.setEditing(false, animated: true)
    }

    @IBAction private func done() {
        delegate?.controllerDidFinish(self)
    }

    @IBAction private func showSettings() {
        delegate?.controllerDidSelectShowSettings(self)
    }

    @IBAction private func createNewDump() {
        delegate?.controllerDidSelectCreateNewDump(self)
    }

    @IBAction private func deleteAllUnpinnedDumps() {
        dataSource?.deleteAllUnpinnedDumps()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let dump = dataSource?.dump(at: indexPath) else { return }
        selectedDump = dump
        delegate?.controller(self, didSelectDump: dump)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource?.numberOfSections ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.numberOfDumps(inSection: section) ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DumpCell else { fatalError("Wrong cell id or type.") }

        if let dump = dataSource?.dump(at: indexPath) {
            configure(cell: cell, for: dump)
        }

        return cell
    }

    private func configure(cell: DumpCell, for dump: Dump) {
        let emptyTitle = NSLocalizedString("New Dump", comment: "Default title for an empty dump")
        cell.titleLabel.text = dump.title ?? emptyTitle
        cell.bodyLabel.text = dump.body
        cell.dateLabel.text = dateFormatter.string(from: dump.dateModified)
        cell.isPinned = dump.isPinned

        if let expiration = dataSource?.expirationDate(for: dump) {
            cell.expirationLabel.text = expirationFormatter.string(from: Date(), to: expiration)
        } else {
            cell.expirationLabel.text = nil
        }
    }

    private func reconfigure(cellAt indexPath: IndexPath, for dump: Dump) {
        guard let cell = tableView.cellForRow(at: indexPath) as? DumpCell else { return }
        configure(cell: cell, for: dump)
    }

    private func reconfigureVisibleCells() {
        guard let dataSource = dataSource else { return }

        (tableView.indexPathsForVisibleRows ?? [])
            .map { ($0, dataSource.dump(at: $0)) }
            .forEach(reconfigure)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard dataSource?.showsHeader(forSection: section) == true else { return nil }
        let view = UIView(frame: .zero)
        view.backgroundColor = sectionSeparatorColor
        return view
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard dataSource?.showsHeader(forSection: section) == true else { return 0 }
        return sectionHeaderHeight
    }

    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        DispatchQueue.main.async {  // Doesn't seem to work without.
            self.selectDump(self.selectedDump)
        }
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let actions = [
            deleteAction(for: indexPath),
            pinAction(for: indexPath),
            shareAction(for: indexPath)
        ]

        return UISwipeActionsConfiguration(actions: actions.compactMap { $0 })
    }

    override func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return action == #selector(UIResponder.copy(_:))
    }

    override func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        guard action == #selector(UIResponder.copy(_:)) else { return }
        UIPasteboard.general.string = dataSource?.dump(at: indexPath).text
    }

    private func configureDataSource() {
        dataSource?.dumpsWillChange = tableView.beginUpdates
        dataSource?.dumpsDidChange = tableView.endUpdates
        dataSource?.sectionDidChange = tableView.applyChange

        dataSource?.dumpDidChange = { [weak self] change in
            self?.tableView.applyChange(change, cellUpdater: { object, indexPath in
                guard let dump = object as? Dump else { return }
                self?.reconfigure(cellAt: indexPath, for: dump)
            })
        }

        tableView.reloadData()
    }

    private func configureSearchController() {
        definesPresentationContext = true

        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        searchController.searchBar.tintColor = view.tintColor
        searchController.dimsBackgroundDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = dataSource?.searcher

        dataSource?.searcher.resultsDidUpdate = { [weak self] _ in
            self?.tableView.reloadData()
        }
    }

    private func selectDump(_ dump: Dump?) {
        guard let dump = dump,
            let indexPath = dataSource?.indexPath(of: dump) else {
                tableView.selectRow(at: nil, animated: true, scrollPosition: .none)
                return
        }

        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
    }
}

// #MARK: Swipe Actions

private extension DumpsViewController {

    func deleteAction(for indexPath: IndexPath) -> UIContextualAction {
        let title = NSLocalizedString("Delete", comment: "")

        return UIContextualAction(style: .destructive, title: title) { [weak self] action, _, completion in
            guard let dataSource = self?.dataSource else {
                completion(false)
                return
            }

            dataSource.deleteDump(at: indexPath)
            completion(true)
        }
    }

    func shareAction(for indexPath: IndexPath) -> UIContextualAction {
        let title = NSLocalizedString("Share", comment: "")

        return UIContextualAction(style: .normal, title: title) { [weak self] action, _, completion in
            let text = self?.dataSource?.dump(at: indexPath).text ?? ""
            let controller = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            self?.present(controller, animated: true)
            completion(true)
        }
    }

    func pinAction(for indexPath: IndexPath) -> UIContextualAction? {
        guard let dump = dataSource?.dump(at: indexPath) else { return nil }
        let title = dump.isPinned ? NSLocalizedString("Unpin", comment: "") : NSLocalizedString("Pin", comment: "")

        let action = UIContextualAction(style: .normal, title: title) { [weak self] action, _, completion in
            dump.isPinned = !dump.isPinned
            self?.dataSource?.save()
            completion(true)
        }

        action.backgroundColor = pinActionColor
        return action
    }
}
