//
//  DataSource.swift
//  RemindersApp
//
//  Created by davidlaiymani on 05/06/2019.
//  Copyright © 2019 davidlaiymani. All rights reserved.
//

import Foundation
import UIKit
import CoreData

// Data source for the Master TableView i.e. list of Reminders
class DataSource: NSObject, UITableViewDataSource {
    
    private let tableView: UITableView
    private let context: NSManagedObjectContext // CoreData context
    
    // CoreData fetch controller
    lazy var fetchResultsController: ReminderFetchResultsController = {
        return ReminderFetchResultsController(fetchRequest: Reminder.fetchRequest(), managedObjectContext: self.context, tableView: self.tableView)
    }()
    
    init(tableView: UITableView, context: NSManagedObjectContext) {
        self.tableView = tableView
        self.context = context
    }
    
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchResultsController.sections {
            return sections.count
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = fetchResultsController.sections?[section] else {
            return 0
        }
        
        return section.numberOfObjects
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath) as! ReminderCell
        
        return configureCell(cell, at: indexPath)
    }
    
    // Deleting a row i.e. a Note
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let reminder = fetchResultsController.object(at: indexPath)
        context.delete(reminder)
        context.saveChanges()
        tableView.reloadData()
    }
    
    // Display a note in a cell
    private func configureCell(_ cell: ReminderCell, at indexPath: IndexPath) -> ReminderCell {
        let reminder = fetchResultsController.object(at: indexPath)
        
        cell.titleLabel.text = reminder.title
        cell.locationLabel.text = reminder.locationDescription
        
        
        return cell
    }
    
    // MARK: - Helpers
    
    // Returns the Note at a given IndexPath
    func object(at indexPath: IndexPath) -> Reminder {
        return fetchResultsController.object(at: indexPath)
    }
    
    
}
