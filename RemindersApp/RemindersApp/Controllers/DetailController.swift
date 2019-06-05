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

class DetailController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var recurrenceSegmentedControl: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    
    
    var managedObjectContext: NSManagedObjectContext!

    var coordinate = Coordinate(latitude: 0.0, longitude: 0.0)
    var locationDescription = "📍 No Location"
    var update:Bool = false // true if a cell has been tapped in the Master Controller
    
    var reminder: Reminder? // The reminder to create or update
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.title = Date().dateOfTheDay()
       
        mapView.delegate = self
        configureView()
        
    }
    
    
    func configureView() {
        locationLabel.text = locationDescription
        
        if let reminder = reminder {
            titleTextField.text = reminder.title
            
            // location info management
            locationLabel.text = reminder.locationDescription
            if (reminder.latitude != 0.0 && reminder.longitude != 0.0) {
                locationButton.setTitle(" Modify Location", for: .normal)
            }
            self.coordinate = Coordinate(latitude: reminder.latitude, longitude: reminder.longitude)
            //locationDescription = reminder.locationDescription
            adjustMap(with: coordinate)
        }
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
        
        // create a new note only if text is non empty
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
        self.locationLabel.text = locationDescription
        self.adjustMap(with: coordinate)
    }
}


// MARK: - MapKit
extension DetailController {
    // Adjust the map around the current location and display an annotation at this location
    func adjustMap(with coordinate: Coordinate) {
        let coordinate2D = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let region = MKCoordinateRegion.init(center: coordinate2D, latitudinalMeters: 500, longitudinalMeters: 500)
        
        mapView.setRegion(region, animated: true)
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
        mapView.addAnnotation(myAnnotation)
        mapView?.addOverlay(MKCircle(center: coordinate2D, radius: CLLocationDistance(exactly: 50.0)!))
        
    }
}

// MARK: - MapView Delegate
extension DetailController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = .purple
            circleRenderer.fillColor = UIColor.purple.withAlphaComponent(0.3)
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
