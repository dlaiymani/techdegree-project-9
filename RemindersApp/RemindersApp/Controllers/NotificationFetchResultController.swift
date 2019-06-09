//
//  NotificationFetchResultController.swift
//  RemindersApp
//
//  Created by davidlaiymani on 06/06/2019.
//  Copyright © 2019 davidlaiymani. All rights reserved.
//

import CoreData

// Get the Reminder info when a notification is sent
class LocationFetchResultsController: NSFetchedResultsController<Reminder> {
    
    init(fetchRequest: NSFetchRequest<Reminder>, managedObjectContext: NSManagedObjectContext) {
        
        super.init(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        tryFetch()
    }
    
    // Perform the fetch operation
    func tryFetch() {
        do {
            try performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
