import UIKit

protocol DumpsViewControllerDelegate: class {
    func controllerDidSelectShowSettings(_ controller: DumpsViewController)
    func controller(_ controller: DumpsViewController, didSelectDump dump: Dump)
    func controller(_ controller: DumpsViewController, didSelectCreateNewDumpWithText text: String?)
}

class DumpsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    weak var delegate: DumpsViewControllerDelegate?

    var dataSource: DumpsDataSource? {
        didSet { configureDataSource() }
    }

    var selectedDump: Dump?  {
        didSet { selectDump(selectedDump) }
    }

    @IBOutlet var tableView: UITableView!
    @IBOutlet private var emptyView: EmptyLibraryView!

    private lazy var searchController = UISearchController(searchResultsController: nil)
    private lazy var updateLabelsTimer = BackgroundPausingTimer(interval: 60, tolerance: 15) { [weak self] in
        self?.reconfigureVisibleCells()
    }

    private let cellIdentifier = "Cell"
    private let headerIdentifier = "Header"

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
        configureViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLabelsTimer.start()
        updateViews()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateLabelsTimer.stop()
        stopEditing()
    }

    @IBAction private func showSettings() {
        delegate?.controllerDidSelectShowSettings(self)
    }

    @IBAction private func createNewDump() {
        delegate?.controller(self, didSelectCreateNewDumpWithText: nil)
    }

    @IBAction private func createNewDumpFromSuggestion() {
        let text = searchController.searchBar.text?.trimmedOrNil
        delegate?.controller(self, didSelectCreateNewDumpWithText: text)
    }

    @IBAction private func deleteAllUnpinnedDumps() {
        presentAlert(.deleteAllUnpinnedDumps { _ in
            self.dataSource?.deleteAllUnpinnedDumps()
        })
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let dump = dataSource?.dump(at: indexPath) else { return }
        selectedDump = dump
        delegate?.controller(self, didSelectDump: dump)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource?.numberOfSections ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.numberOfDumps(inSection: section) ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DumpCell else { fatalError("Wrong cell id or type.") }
        configureCell(cell, for: indexPath)
        return cell
    }

    private func configureCell(_ cell: DumpCell, for indexPath: IndexPath) {
        guard let dump = dataSource?.dump(at: indexPath) else { return }
        cell.configure(with: dump, expirationDate: dataSource?.expirationDate(for: dump))
    }

    private func reconfigureVisibleCells() {
        tableView.indexPathsForVisibleRows?.forEach {
            guard let cell = tableView.cellForRow(at: $0) as? DumpCell else { return }
            configureCell(cell, for: $0)
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerIdentifier) as? LibrarySectionHeader else { fatalError("Wrong header id or type") }
        configureHeader(header, for: section)
        return header
    }

    private func configureHeader(_ header:LibrarySectionHeader, for section: Int) {
        guard let type = dataSource?.sectionType(for: section) else { return }
        let items = dataSource?.numberOfDumps(inSection: section) ?? 0
        header.configure(with: type, numberOfItems: items, actionTarget: self, action: #selector(deleteAllUnpinnedDumps))
    }

    private func reconfigureHeaders() {
        (0..<numberOfSections(in: tableView)).forEach {
            guard let header = tableView.headerView(forSection: $0) as? LibrarySectionHeader else { return }
            configureHeader(header, for: $0)
        }
    }

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        DispatchQueue.main.async {  // Doesn't seem to work without.
            self.updateViews()
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let actions = [
            deleteAction(for: indexPath),
            pinAction(for: indexPath),
            shareAction(for: indexPath)
        ]

        return UISwipeActionsConfiguration(actions: actions.compactMap { $0 })
    }

    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return action == #selector(UIResponder.copy(_:))
    }

    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        guard action == #selector(UIResponder.copy(_:)) else { return }
        UIPasteboard.general.string = dataSource?.dump(at: indexPath).text
    }

    private func configureDataSource() {
        guard isViewLoaded else { return }

        dataSource?.dumpsWillChange = { [weak self] hasIncrementalChanges in
            guard hasIncrementalChanges else { return }
            self?.tableView.beginUpdates()
        }

        dataSource?.sectionDidChange = { [weak self]  change in
            self?.tableView.applyChange(change)
        }

        dataSource?.dumpDidChange = { [weak self] change in
            self?.tableView.applyChange(change, cellUpdater: { object, indexPath in
                guard let cell = self?.tableView.cellForRow(at: indexPath) as? DumpCell else { return }
                self?.configureCell(cell, for: indexPath)
            })
        }

        dataSource?.dumpsDidChange = { [weak self] hasIncrementalChanges in
            if hasIncrementalChanges {
                self?.tableView.endUpdates()
            } else {
                self?.tableView.reloadData()
            }
            self?.updateViews()
        }

        dataSource?.dumpsDidChange?(false)
    }

    private func configureViews() {
        navigationController?.navigationBar.barTintColor = Style.mainBackgroundColor
        view.backgroundColor = Style.mainBackgroundColor
        tableView.backgroundColor = Style.mainBackgroundColor
        tableView.backgroundView = emptyView
        tableView.register(LibrarySectionHeader.nib, forHeaderFooterViewReuseIdentifier: headerIdentifier)

        definesPresentationContext = true
        searchController.searchResultsUpdater = dataSource
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = NSLocalizedString("Search Thoughts", comment: "")
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.backgroundColor = Style.mainBackgroundColor
        tableView.tableHeaderView = searchController.searchBar

        updateViews()
    }

    private func selectDump(_ dump: Dump?) {
        guard isViewLoaded else { return }

        guard let dump = dump,
            let indexPath = dataSource?.indexPath(of: dump) else {
                tableView.selectRow(at: nil, animated: true, scrollPosition: .none)
                return
        }

        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
    }

    private func updateViews() {
        selectDump(selectedDump)
        emptyView.configure(with: searchController.searchBar.text, isEmpty: dataSource?.isEmpty ?? true)
        reconfigureHeaders()
    }

    private func stopEditing() {
        tableView.setEditing(false, animated: true)
        searchController.searchBar.endEditing(true)
    }
}

extension DumpsViewController: UISearchBarDelegate {

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {  // Timing issue with `isActive`.
            guard self.searchController.isActive,
                (searchBar.text == "") || (searchBar.text == nil) else { return }
            self.searchController.isActive = false
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateViews()  
    }
}

// #MARK: Swipe Actions

private extension DumpsViewController {

    func deleteAction(for indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: title) { [weak self] action, _, completion in
            guard let dataSource = self?.dataSource else {
                completion(false)
                return
            }

            dataSource.deleteDump(at: indexPath)
            completion(true)
        }

        action.image = #imageLiteral(resourceName: "trash-large")
        action.backgroundColor = Style.red
        return action
    }

    func shareAction(for indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: title) { [weak self] action, _, completion in
            let text = self?.dataSource?.dump(at: indexPath).text ?? ""
            let controller = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            self?.present(controller, animated: true)
            completion(true)
        }

        action.image = #imageLiteral(resourceName: "share-large")
        action.backgroundColor = Style.mainTint
        return action
    }

    func pinAction(for indexPath: IndexPath) -> UIContextualAction? {
        guard let dump = dataSource?.dump(at: indexPath) else { return nil }

        let action = UIContextualAction(style: .normal, title: title) { [weak self] action, _, completion in
            dump.isPinned = !dump.isPinned
            self?.dataSource?.save()
            completion(true)
        }

        action.image = dump.isPinned ? #imageLiteral(resourceName: "unpin-large") : #imageLiteral(resourceName: "pin-large")
        action.backgroundColor = Style.orange
        return action
    }
}
