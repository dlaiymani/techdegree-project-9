//
//  MasterController.swift
//  RemindersApp
//
//  Created by davidlaiymani on 05/06/2019.
//  Copyright © 2019 davidlaiymani. All rights reserved.
//

import UIKit
import CoreData

// The Master Controler Class
class MasterController: UITableViewController {
    
    let managedObjectContext = CoreDataStack().managedObjectContext

    lazy var dataSource: DataSource = {
        return DataSource(tableView: self.tableView, context: self.managedObjectContext)
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        tableView.dataSource = dataSource
        tableView.delegate = self

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
    }

    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddReminder" { // New reminder button tapped
            
            let navigatioController = segue.destination as! UINavigationController
            let addReminderController = navigatioController.topViewController as! DetailController
            
            addReminderController.managedObjectContext = self.managedObjectContext
            addReminderController.update = false
        } else if segue.identifier == "UpdateReminder" { // A cell (a reminder) has been tapped
            let navigationController = segue.destination as! UINavigationController
            let updateReminderController = navigationController.topViewController as! DetailController
            updateReminderController.update = true
            if let indexPath = tableView.indexPathForSelectedRow { // The tapped cell
                let reminder = dataSource.object(at: indexPath)
                updateReminderController.reminder = reminder
                updateReminderController.managedObjectContext = self.managedObjectContext
            }
        }
    }
    

}
