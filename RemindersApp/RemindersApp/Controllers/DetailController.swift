//
//  DetailController.swift
//  RemindersApp
//
//  Created by davidlaiymani on 05/06/2019.
//  Copyright © 2019 davidlaiymani. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit

class DetailController: UITableViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var recurrenceSegmentedControl: UISegmentedControl!
    @IBOutlet weak var geofenceSwitch: UISwitch!
 //   @IBOutlet weak var staticLocationLabel: UILabel!
    
    var staticLocationLabel: UILabel!
    var locationLabel: UILabel!
    var cell: UITableViewCell!
    
    var staticLabelVerticalConstraint: NSLayoutConstraint!
    var staticLabelLeadingConstraint: NSLayoutConstraint!
    var staticLabelTopConstraint: NSLayoutConstraint!
    
    var locationLabelLeadingConstraint: NSLayoutConstraint!
    var locationLabelBottomConstraint: NSLayoutConstraint!

    
    var managedObjectContext: NSManagedObjectContext!
    
    
    var coordinate = Coordinate(latitude: 0.0, longitude: 0.0)
    var locationDescription = ""
    var update:Bool = false // true if a cell has been tapped in the Master Controller
    
    var reminder: Reminder? // The reminder to create or update
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        
        if let reminder = reminder {
            titleTextField.text = reminder.title
            notesTextView.text = reminder.notes
            locationDescription = reminder.locationDescription ?? ""
            coordinate = Coordinate(latitude: reminder.latitude, longitude: reminder.longitude)
        }

        staticLocationLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 21))
        staticLocationLabel.text = "Location"
        staticLocationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        locationLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 21))
        locationLabel.text = locationDescription
        locationLabel.textColor = .lightGray
        locationLabel.translatesAutoresizingMaskIntoConstraints = false

        cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 2))
        cell.contentView.addSubview(staticLocationLabel)
        cell?.contentView.addSubview(locationLabel)
        
        staticLabelVerticalConstraint = NSLayoutConstraint(item: staticLocationLabel!, attribute: .centerY, relatedBy: .equal, toItem: cell.contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        staticLabelLeadingConstraint = NSLayoutConstraint(item: staticLocationLabel!, attribute: .leading, relatedBy: .equal, toItem: cell.contentView, attribute: .leadingMargin, multiplier: 1.0, constant: 0.0)
        staticLabelTopConstraint = NSLayoutConstraint(item: staticLocationLabel!, attribute: .top, relatedBy: .equal, toItem: cell.contentView, attribute: .topMargin, multiplier: 1.0, constant: 8.0)
        locationLabelLeadingConstraint = NSLayoutConstraint(item: locationLabel!, attribute: .leading, relatedBy: .equal, toItem: cell.contentView, attribute: .leadingMargin, multiplier: 1.0, constant: 0.0)
        locationLabelBottomConstraint = NSLayoutConstraint(item: locationLabel!, attribute: .bottom, relatedBy: .equal, toItem: cell.contentView, attribute: .bottomMargin, multiplier: 1.0, constant: -8.0)
        
        staticLabelLeadingConstraint.isActive = true
        locationLabelBottomConstraint.isActive = true
        locationLabelLeadingConstraint.isActive = true
        
        configureView()
        
    }
    
    
    func configureView() {
        tableView.reloadData()
        
        if coordinate.isNotSet() {
            staticLabelVerticalConstraint.isActive = true
            staticLabelTopConstraint.isActive = false
            
            locationLabel.isHidden = true
            geofenceSwitch.isOn = false
            
        } else {
            print(locationDescription)
            locationLabel.text = locationDescription
            locationLabel.isHidden = false
            
            geofenceSwitch.isOn = true

            staticLabelVerticalConstraint.isActive = false
            staticLabelTopConstraint.isActive = true
            
            
            view.layoutIfNeeded()
            
        }
        
    }
    
    
    @IBAction func geofenceSwitchToggled(_ sender: Any) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        
        guard let title = titleTextField.text, !title.isEmpty else {
            return
        }
        
        // if update: delete the reminders and create a new one. Not sure it is the best way to do
        // but don't figure out to use the setValue methods
        if update {
            managedObjectContext.delete(self.reminder!)
        }
        
        // create a new reminder only if text is non empty
        let reminder = NSEntityDescription.insertNewObject(forEntityName: "Reminder", into: managedObjectContext) as! Reminder
        
        reminder.title = title
        reminder.notes = notesTextView.text
        reminder.latitude = coordinate.latitude
        reminder.longitude = coordinate.longitude
        reminder.locationDescription = locationDescription
        if recurrenceSegmentedControl.selectedSegmentIndex == 0 {
            reminder.recurrence = true
        } else {
            reminder.recurrence = false
        }
        managedObjectContext.saveChanges()
        dismiss(animated: true, completion: nil)    }
    
    
    // back from location controller
    @IBAction func unwindFromLocationController(_ segue: UIStoryboardSegue) {

        configureView()

    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let locationController = segue.destination as! LocationController
        print(coordinate.latitude)
        locationController.coordinate = coordinate
    }
    
    
    // MARK: - TableView delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 2 && indexPath.row == 1) { // This is the cell to hide - change as you need
            // Show or hide cell
            if (self.geofenceSwitch.isOn) {
                return 88; // Show the cell - adjust the height as you need
            } else {
                return 0; // Hide the cell
            }
        }
        
        if (indexPath.section == 0 && indexPath.row == 0) {
            return 200
        } else {
            return 44
        }
    }
    
    
}



