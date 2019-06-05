//
//  LocationController.swift
//  RemindersApp
//
//  Created by davidlaiymani on 05/06/2019.
//  Copyright © 2019 davidlaiymani. All rights reserved.
//

import Foundation
import MapKit

class LocationController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var alertingSegmentedControl: UISegmentedControl!
    
    lazy var locationManager: LocationManager = {
        return LocationManager(delegate: self, permissionsDelegate: nil)
    }()
    
    var locationDescription = "📍 No Location"
    
    // Find an address from coordinates
    var geocoder = CLGeocoder()
    var coordinate: Coordinate? { // When coordinates are set the perform geocoding
        didSet {
            if let coordinate = coordinate {
                let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                geocoder.reverseGeocodeLocation(location) { placemarks, error in
                    if let error = error {
                        print(error)
                        
                        let alertError = AlertError(error: .unableToFindLocation, on: self)
                    } else {
                        if let placemarks = placemarks, let placemark = placemarks.first, let name = placemark.name, let locality = placemark.locality, let adminArea = placemark.administrativeArea {
                            self.locationDescription = "\(name), \(locality), \(adminArea)"
                        } else {
                            print("No matching address found")
                        }
                    }
                }
            }
        }
    }
    
    
    // Check location authorization
    var isAuthorized: Bool {
        let isAuthorizedForLocation = LocationManager.isAuthorized
        return isAuthorizedForLocation
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Check permission or request the current location
    override func viewDidAppear(_ animated: Bool) {
        if isAuthorized {
      //      locationManager.requestLocation()
        } else {
            checkPermissions()
        }
    }
    
    func checkPermissions() {
        do {
            try locationManager.requestLocationAuthorization()
        } catch LocationError.disallowedByUser {
            // Show alert to users
            print("error")
        } catch let error {
            print("Location Authorization error \(error.localizedDescription)")
        }
    }
    
    
    @IBAction func getCurrentLocation(_ sender: UIButton) {
        if isAuthorized {
            locationManager.requestLocation()
        } else {
            checkPermissions()
        }
    }
    
    
}





// MARK: - Location Manager Delegate
extension LocationController: LocationManagerDelegate {
    func obtainedCoordinates(_ coordinate: Coordinate) {
        self.coordinate = coordinate
        adjustMap(with: coordinate)
    }
    
    func failedWithError(_ error: LocationError) {
        let alertError = AlertError(error: error, on: self)
        alertError.displayAlert()
    }
}

// MARK: - MapKit
extension LocationController {
    // Adjust the map around the current location and display an annotation at this location
    func adjustMap(with coordinate: Coordinate) {
        let coordinate2D = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let region = MKCoordinateRegion.init(center: coordinate2D, latitudinalMeters: 2500, longitudinalMeters: 2500)
        
        mapView.setRegion(region, animated: true)
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
        mapView.addAnnotation(myAnnotation)
    }
}
