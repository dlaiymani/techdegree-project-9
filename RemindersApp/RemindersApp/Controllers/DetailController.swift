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

// The Detail Controller class
class DetailController: UITableViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var geofenceSwitch: UISwitch!
    @IBOutlet var tapOnView: UITapGestureRecognizer! // to dismiss the keyboard with a tap
    
    // CoreData
    var managedObjectContext: NSManagedObjectContext!
    
    // Objects and Layout constraints for the Location cell
    var staticLocationLabel: UILabel!
    var locationLabel: UILabel!
    var cell: UITableViewCell!
    var staticLabelVerticalConstraint: NSLayoutConstraint!
    var staticLabelLeadingConstraint: NSLayoutConstraint!
    var staticLabelTopConstraint: NSLayoutConstraint!
    var locationLabelLeadingConstraint: NSLayoutConstraint!
    var locationLabelBottomConstraint: NSLayoutConstraint!

    
    var coordinate = Coordinate(latitude: 0.0, longitude: 0.0)
    var locationDescription = ""
    var eventType: Bool = false // Arriving = true
    var update:Bool = false // true if a cell has been tapped in the Master Controller
    
    var reminder: Reminder? // The reminder to create or update
    
    var locationManager: LocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        titleTextField.delegate = self
        notesTextView.delegate = self
        
        // Update an exsisting reminder
        if let reminder = reminder {
            titleTextField.text = reminder.title
            notesTextView.text = reminder.notes
            locationDescription = reminder.locationDescription ?? ""
            coordinate = Coordinate(latitude: reminder.latitude, longitude: reminder.longitude)
            eventType = reminder.eventType
        }

        configureLocationCell()
        configureView()
    }
    
    
    func configureLocationCell() {
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
    
    // Activate (desactivate) the geofencing
    @IBAction func geofenceSwitchToggled(_ sender: Any) {
        tableView.beginUpdates()
        tableView.endUpdates()
        
        if geofenceSwitch.isOn == false {
            if let locationManager = locationManager,  let reminder = reminder {
                locationManager.stopMonitoring(reminder: reminder)
            }
            coordinate.latitude = 0.0
            coordinate.longitude = 0.0
            locationDescription = ""
            configureView()
        }
    }
    
    // Dismiss UITextview keyboard
    @IBAction func dismissKeyboard(_ sender: Any) {
        notesTextView.resignFirstResponder()
        titleTextField.resignFirstResponder()
    }
    
    // Back to Master View
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // Save the reminder with CoreData
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        guard let title = titleTextField.text, !title.isEmpty else {
            return
        }
        
        // If update: delete the reminders and create a new one. Not sure it is the best way to do
        // but don't figure out to use the setValue methods
        if update {
            managedObjectContext.delete(self.reminder!)
        }
        
        // Create a new reminder only if text is non empty
        let reminder = NSEntityDescription.insertNewObject(forEntityName: "Reminder", into: managedObjectContext) as! Reminder
        
        reminder.title = title
        reminder.notes = notesTextView.text
        reminder.latitude = coordinate.latitude
        reminder.longitude = coordinate.longitude
        reminder.locationDescription = locationDescription
        reminder.eventType = eventType
        
        if let locationManager = locationManager {
            locationManager.startMonitoring(reminder: reminder)
        }
        
        managedObjectContext.saveChanges()
        dismiss(animated: true, completion: nil)
    }
    
    
    // Back from location controller
    @IBAction func unwindFromLocationController(_ segue: UIStoryboardSegue) {
        configureView()
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
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let locationController = segue.destination as! LocationController
        locationController.coordinate = coordinate
        locationController.eventType = eventType
    }
}


// In order to dismiss the keyboard
extension DetailController: UITextFieldDelegate, UITextViewDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.titleTextField.resignFirstResponder()
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        self.notesTextView.resignFirstResponder()
        return true
    }
}
