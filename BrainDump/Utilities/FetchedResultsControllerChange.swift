import CoreData

struct FetchedResultsControllerSectionChange {
    let type: NSFetchedResultsChangeType
    let index: Int
}

struct FetchedResultsControllerObjectChange {
    let object: Any
    let type: NSFetchedResultsChangeType
    let indexPath: IndexPath?
    let newIndexPath: IndexPath?
}

// MARK: UITableView

import UIKit

extension UITableView {

    func applyChange(_ change: FetchedResultsControllerSectionChange) {
        let animation = UITableView.RowAnimation.fade

        switch change.type {
        case .insert:
            insertSections([change.index], with: animation)
        case .delete:
            deleteSections([change.index], with: animation)
        default:
            break
        }
    }

    func applyChange(_ change: FetchedResultsControllerObjectChange, cellUpdater: @escaping(Any, IndexPath) -> ()) {
        let animation = UITableView.RowAnimation.none

        switch change.type {

        case .insert:
            guard let indexPath = change.newIndexPath else { return }
            insertRows(at: [indexPath], with: animation)

        case .delete:
            guard let indexPath = change.indexPath else { return }
            deleteRows(at: [indexPath], with: animation)

        case .update:
            guard let indexPath = change.indexPath else { return }
            // Apple recommends to reconfigure instead of reloading the cell
            cellUpdater(change.object, indexPath)

        case .move:
            guard let from = change.indexPath,
                let to = change.newIndexPath  else { return }
            deleteRows(at: [from], with: animation)
            insertRows(at: [to], with: animation)

        @unknown default:
            fatalError()
        }
    }
}
