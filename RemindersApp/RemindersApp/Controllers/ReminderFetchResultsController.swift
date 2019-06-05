//
//  ReminderFetchResultsController.swift
//  RemindersApp
//
//  Created by davidlaiymani on 05/06/2019.
//  Copyright © 2019 davidlaiymani. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ReminderFetchResultsController: NSFetchedResultsController<Reminder>, NSFetchedResultsControllerDelegate {
    
    private let tableView: UITableView
    private var nbOfSections = 0
    
    // Initiate a CoreData request on Notes and associate a tableview to it
    init(fetchRequest: NSFetchRequest<Reminder>, managedObjectContext: NSManagedObjectContext, tableView: UITableView) {
        self.tableView = tableView
        
        super.init(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        self.delegate = self
        
        tryFetch()
    }
    
    // perform the fetch operation
    func tryFetch() {
        do {
            try performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - FetchResultController Delegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
        nbOfSections = self.sections!.count
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            tableView.reloadData()
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .update, .move:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}
