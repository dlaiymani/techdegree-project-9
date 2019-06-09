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
        return DataSource(tableView: self.tableView, context: self.managedObjectContext, locationManager: self.locationManager!)
    }()
    
    var locationManager: LocationManager?
    // Check location authorization
    var isAuthorized: Bool = false
    
    var nextViewController: DetailController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager = LocationManager(delegate: self, permissionsDelegate: nil)
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        
        tableView.dataSource = dataSource
        tableView.delegate = self

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
    }

    override func viewWillAppear(_ animated: Bool) {
        let isAuthorized = LocationManager.isAuthorized
        
        if !isAuthorized {
            checkPermissions()
        }
        
        tableView.reloadData()
    }
    
    func checkPermissions() {
        do {
            try locationManager?.requestLocationAuthorization()
        } catch LocationError.disallowedByUser {
            self.showAlert(withTitle: "ReminderApp needs your location data", message: "Please, see your settings configuration")
        } catch let error {
            print("Location Authorization error \(error.localizedDescription)")
        }
    }
    
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "AddReminder" { // New reminder button tapped
            let navigationController = segue.destination as! UINavigationController

            let addReminderController = navigationController.topViewController as! DetailController
            self.nextViewController = addReminderController
            
            addReminderController.managedObjectContext = self.managedObjectContext
            addReminderController.update = false
            addReminderController.locationManager = self.locationManager
        } else if segue.identifier == "UpdateReminder" { // A cell (a reminder) has been tapped
            let navigationController = segue.destination as! UINavigationController
            let updateReminderController = navigationController.topViewController as! DetailController
            self.nextViewController = updateReminderController

            updateReminderController.update = true
            if let indexPath = tableView.indexPathForSelectedRow { // The tapped cell
                let reminder = dataSource.object(at: indexPath)
                updateReminderController.reminder = reminder
                updateReminderController.managedObjectContext = self.managedObjectContext
                updateReminderController.locationManager = self.locationManager
            }
        }
    }
}


// MARK: - Location Manager Delegate
extension MasterController: LocationManagerDelegate {
    func obtainedCoordinates(_ coordinate: Coordinate) {
    }
    
    func failedWithError(_ error: LocationError) {
        let alertError = AlertError(error: error, on: self)
        alertError.displayAlert()
    }
}
