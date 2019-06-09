//
//  Reminder+CoreDataProperties.swift
//  RemindersApp
//
//  Created by davidlaiymani on 05/06/2019.
//  Copyright © 2019 davidlaiymani. All rights reserved.
//
//

import Foundation
import CoreData


// The reminder type
extension Reminder {

    // Fetch all the reminders
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Reminder> {
        let request = NSFetchRequest<Reminder>(entityName: "Reminder")
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        return request
    }
    
    
    // Fetch the reminders with a given title
    @nonobjc  class func fetchRequestWithText(_ title: String) -> NSFetchRequest<Reminder> {
        
        let request = NSFetchRequest<Reminder>(entityName: "Reminder")
        
        let predicate  = NSPredicate(format: "title == %@", title)
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        return request
    }

    @NSManaged public var title: String?
    @NSManaged public var locationDescription: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var notes: String?
    @NSManaged public var eventType: Bool

}
