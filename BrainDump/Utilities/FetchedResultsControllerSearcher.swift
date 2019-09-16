import CoreData
import UIKit

/// Handles searching for a `NSFetchedResultsController` instance.
class FetchedResultsControllerSearcher<T: NSManagedObject>: NSObject, UISearchResultsUpdating {

    var resultsDidUpdate: ((NSFetchedResultsController<T>) -> ())?

    private let frc: NSFetchedResultsController<T>
    private let searchKeyPath: String
    private let debounceBy: TimeInterval?
    private var searchTerm: String?

    /// The fetched results controller's fetch request predicate is set to reflect the
    /// search term. Any existing predicate is cleared.
    /// Currently only searching on the main thread is supported (the frc's managed object
    /// context must be associated with the main queue).
    init(frc: NSFetchedResultsController<T>, searchKeyPath: String, debounceBy: TimeInterval?) {
        self.frc = frc
        self.frc.fetchRequest.predicate = nil
        self.searchKeyPath = searchKeyPath
        self.debounceBy = debounceBy
    }

    func search(for term: String?) {
        let term = term?.trimmedOrNil
        guard term != searchTerm else { return }
        searchTerm = term

        // When term is nil, perform (un-)search immediately.
        if let delay = debounceBy,
            searchTerm != nil {

            let action = #selector(performSearch)
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: action, object: nil)
            perform(action, with: nil, afterDelay: delay)
        } else {
            performSearch()
        }
    }

    @objc private func performSearch() {
        if let term = searchTerm {
            frc.fetchRequest.predicate = NSPredicate(format: "%K CONTAINS[cd] %@", searchKeyPath, term)
        } else {
            frc.fetchRequest.predicate = nil
        }

        try? frc.performFetch()
        resultsDidUpdate?(frc)
    }

    func updateSearchResults(for searchController: UISearchController) {
        search(for: searchController.searchBar.text)
    }
}
