import UIKit

protocol LibraryViewControllerDelegate: class {
    func controllerDidSelectShowSettings(_ controller: LibraryViewController)
    func controller(_ controller: LibraryViewController, didSelectNote note: Note)
    func controller(_ controller: LibraryViewController, didSelectCreateNewNoteWithText text: String?)
}

class LibraryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    weak var delegate: LibraryViewControllerDelegate?

    var dataSource: LibraryDataSource? {
        didSet { configureDataSource() }
    }

    var selectedNote: Note?  {
        didSet { selectNote(selectedNote) }
    }

    @IBOutlet var tableView: UITableView!
    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var emptyView: EmptyLibraryView!

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

    @IBAction private func createNewNote() {
        delegate?.controller(self, didSelectCreateNewNoteWithText: nil)
    }

    @IBAction private func createNewNoteFromSuggestion() {
        let text = searchBar.text?.trimmedOrNil
        delegate?.controller(self, didSelectCreateNewNoteWithText: text)
    }

    @IBAction private func deleteAllUnpinnedNotes() {
        presentAlert(.deleteAllUnpinnedNotes { _ in
            self.dataSource?.deleteAllUnpinnedNotes()
        })
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let note = dataSource?.note(at: indexPath) else { return }
        selectedNote = note
        delegate?.controller(self, didSelectNote: note)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        dataSource?.numberOfSections ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource?.numberOfNotes(inSection: section) ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? NoteCell else { fatalError("Wrong cell id or type.") }
        configureCell(cell, for: indexPath)
        return cell
    }

    private func configureCell(_ cell: NoteCell, for indexPath: IndexPath) {
        guard let note = dataSource?.note(at: indexPath) else { return }
        cell.configure(with: note, expirationDate: dataSource?.expirationDate(for: note))
    }

    private func reconfigureVisibleCells() {
        tableView.indexPathsForVisibleRows?.forEach {
            guard let cell = tableView.cellForRow(at: $0) as? NoteCell else { return }
            configureCell(cell, for: $0)
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerIdentifier) as? LibrarySectionHeader else { fatalError("Wrong header id or type") }
        configureHeader(header, for: section)
        return header
    }

    private func configureHeader(_ header: LibrarySectionHeader, for section: Int) {
        guard let type = dataSource?.sectionType(for: section) else { return }
        let items = dataSource?.numberOfNotes(inSection: section) ?? 0
        header.configure(with: type, numberOfItems: items, actionTarget: self, action: #selector(deleteAllUnpinnedNotes))
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

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let dataSource = dataSource else { return nil }
        let note = dataSource.note(at: indexPath)

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            UIMenu(title: "", children: [
                PinAction(note: note).menuAction(),
                DuplicateAction(note: note, dataSource: dataSource).menuAction(),
                ShareAction(note: note, presentingViewController: self).menuAction(),
                DeleteAction(note: note, dataSource: dataSource).menuAction()
            ])
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let dataSource = dataSource else { return nil }
        let note = dataSource.note(at: indexPath)

        return UISwipeActionsConfiguration(actions: [
            DeleteAction(note: note, dataSource: dataSource).swipeAction(),
            PinAction(note: note).swipeAction(),
            ShareAction(note: note, presentingViewController: self).swipeAction()
        ])
    }

    private func configureDataSource() {
        guard isViewLoaded else { return }

        dataSource?.notesWillChange = { [weak self] hasIncrementalChanges in
            // Console warns we should not modify the table view if it's not being displayed.
            guard self?.view.window != nil,
                hasIncrementalChanges else { return }
            self?.tableView.beginUpdates()
        }

        dataSource?.sectionDidChange = { [weak self]  change in
            guard self?.view.window != nil else { return }
            self?.tableView.applyChange(change)
        }

        dataSource?.noteDidChange = { [weak self] change in
            guard self?.view.window != nil else { return }

            self?.tableView.applyChange(change, cellUpdater: { object, indexPath in
                guard let cell = self?.tableView.cellForRow(at: indexPath) as? NoteCell else { return }
                self?.configureCell(cell, for: indexPath)
            })
        }

        dataSource?.notesDidChange = { [weak self] hasIncrementalChanges in
            guard self?.view.window != nil else {
                self?.tableView.reloadData()
                return
            }

            if hasIncrementalChanges {
                self?.tableView.endUpdates()
            } else {
                self?.tableView.reloadData()
            }
            self?.updateViews()
        }

        dataSource?.notesDidChange?(false)
    }

    private func configureViews() {
        view.backgroundColor = tableView.backgroundColor
        searchBar.backgroundColor = tableView.backgroundColor

        tableView.backgroundView = emptyView
        tableView.register(LibrarySectionHeader.nib, forHeaderFooterViewReuseIdentifier: headerIdentifier)

        searchBar.delegate = self

        updateViews()
    }

    private func selectNote(_ note: Note?) {
        guard isViewLoaded else { return }

        guard let note = note,
            let indexPath = dataSource?.indexPath(of: note) else {
                tableView.selectRow(at: nil, animated: true, scrollPosition: .none)
                return
        }

        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
    }

    private func updateViews() {
        selectNote(selectedNote)
        emptyView.configure(with: searchBar.text, isEmpty: dataSource?.isEmpty ?? true)
        reconfigureHeaders()
    }

    private func stopEditing() {
        tableView.setEditing(false, animated: true)
        searchBar.endEditing(true)
    }
}

// MARK: - Search

extension LibraryViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        dataSource?.search(for: searchBar.text)
        updateViews()  
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.text = nil
        dataSource?.search(for: searchBar.text)
        updateViews()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        dataSource?.search(for: searchBar.text)
        updateViews()
    }
}
