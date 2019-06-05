//
//  CoreDataStack.swift
//  RemindersApp
//
//  Created by davidlaiymani on 05/06/2019.
//  Copyright © 2019 davidlaiymani. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    // The CoreData context
    lazy var managedObjectContext: NSManagedObjectContext = {
        let container = self.persistentContainer
        return container.viewContext
    }()
    
    //  The CoreData Context
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Reminder")
        container.loadPersistentStores() { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error: \(error), \(error.userInfo)")
            }
            
            storeDescription.shouldInferMappingModelAutomatically = true
            storeDescription.shouldMigrateStoreAutomatically = true
        }
        
        return container
    }()
}


// Save the data on disk
extension NSManagedObjectContext {
    func saveChanges() {
        if self.hasChanges {
            do {
                try save()
            } catch {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
}
