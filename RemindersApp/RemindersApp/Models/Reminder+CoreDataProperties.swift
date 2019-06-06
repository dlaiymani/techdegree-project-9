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


extension Reminder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Reminder> {
        let request = NSFetchRequest<Reminder>(entityName: "Reminder")
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        return request
    }

    @NSManaged public var title: String?
    @NSManaged public var locationDescription: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var notes: String?
    @NSManaged public var recurrence: Bool
    @NSManaged public var eventType: Bool



}
