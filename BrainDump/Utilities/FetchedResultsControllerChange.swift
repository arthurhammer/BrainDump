import CoreData

struct FetchedResultsControllerChange {
    let object: Any
    let type: NSFetchedResultsChangeType
    let indexPath: IndexPath?
    let newIndexPath: IndexPath?
}


import UIKit

extension UITableView {
    func applyChange(_ change: FetchedResultsControllerChange, cellUpdater: @escaping(Any, IndexPath) -> ()) {
        switch change.type {

        case .insert:
            guard let indexPath = change.newIndexPath else { return }
            insertRows(at: [indexPath], with: .automatic)

        case .delete:
            guard let indexPath = change.indexPath else { return }
            deleteRows(at: [indexPath], with: .automatic)

        case .update:
            guard let indexPath = change.indexPath else { return }
            // Apple recommends to reconfigure instead of reloading the cell
            cellUpdater(change.object, indexPath)

        case .move:
            guard let from = change.indexPath,
                let to = change.newIndexPath  else { return }
            deleteRows(at: [from], with: .automatic)
            insertRows(at: [to], with: .automatic)

        @unknown default:
            fatalError()
        }
    }
}
