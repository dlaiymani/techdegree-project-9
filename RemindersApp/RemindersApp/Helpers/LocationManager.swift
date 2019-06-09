//
//  LocationManager.swift
//  RemindersApp
//
//  Created by davidlaiymani on 05/06/2019.
//  Copyright © 2019 davidlaiymani. All rights reserved.
//

import Foundation

import CoreLocation


// Possible location error
enum LocationError: Error {
    case unknownError
    case disallowedByUser
    case unableToFindLocation
    case noMatchingAddressFound
}

// The authorization delegate protocol
protocol LocationPermissionsDelegate: class { // the delegate that adopts the protocol must be a class
    func authorizationSucceeded()
    func authorizationFailedWithStatus(_ status: CLAuthorizationStatus)
}

// The location delegate protocol
protocol LocationManagerDelegate: class {
    func obtainedCoordinates(_ coordinate: Coordinate)
    func failedWithError(_ error: LocationError)
}


class LocationManager: NSObject, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    weak var permissionsDelegate: LocationPermissionsDelegate?
    weak var delegate: LocationManagerDelegate?
    
    // State of the authorization
    static var isAuthorized: Bool {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            return true
        default:
            return false
        }
    }
    
    init(delegate: LocationManagerDelegate?, permissionsDelegate: LocationPermissionsDelegate?) {
        self.permissionsDelegate = permissionsDelegate
        self.delegate = delegate
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest // default value
        
    }
    
    // Function which checks and asks the location authorization to the user
    func requestLocationAuthorization() throws {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        if authorizationStatus == .restricted || authorizationStatus == .denied {
            throw LocationError.disallowedByUser
        } else if authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else {
            return
        }
    }
    
    // Function which initiates the location process
    func requestLocation() {
        manager.startUpdatingLocation()
    }
    
    // If the authorization has changed
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways{
            permissionsDelegate?.authorizationSucceeded()
            requestLocation()
        } else {
            permissionsDelegate?.authorizationFailedWithStatus(status)
        }
    }
    
    // Location problem
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let error = error as? CLError else {
            delegate?.failedWithError(.unknownError)
            return
        }
        switch error.code {
        case .locationUnknown, .network:
            delegate?.failedWithError(.unableToFindLocation)
        case .denied:
            delegate?.failedWithError(.disallowedByUser)
        default:
            return
        }
    }
    
    // Location has changed so get the new coordinates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let location = locations.last else {
            print("requestloc")

            delegate?.failedWithError(.unableToFindLocation)
            return
        }
        let coordinate = Coordinate(location: location)
        delegate?.obtainedCoordinates(coordinate)
        print(coordinate.latitude)
        print(coordinate.longitude)
    }
    
    // MARK: - Geofencing
    func region(with reminder: Reminder) -> CLCircularRegion {
        
        let coordinate2D = CLLocationCoordinate2D(latitude: reminder.latitude, longitude: reminder.longitude)
        let region = CLCircularRegion(center: coordinate2D,
                                      radius: CLLocationDistance(exactly: 50.0)!,
                                      identifier: reminder.title!)
        region.notifyOnEntry = (reminder.eventType == false)
        region.notifyOnExit = !region.notifyOnEntry
        return region
    }
    
    
    func startMonitoring(reminder: Reminder) {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            print("Error: Geofencing is not supported on this device!")
          //  showAlert(withTitle:"Error", message: "Geofencing is not supported on this device!")
            return
        }
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            let message = """
      Your geotification is saved but will only be activated once you grant
      Geotify permission to access the device location.
      """
            print(message)
            // showAlert(withTitle:"Warning", message: message)
        }
        let fenceRegion = region(with: reminder)
        
        self.manager.startMonitoring(for: fenceRegion)
    }
    
    func stopMonitoring(reminder: Reminder) {
        for region in manager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion,
                circularRegion.identifier == reminder.title else { continue }
            manager.stopMonitoring(for: circularRegion)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?,
                         withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
}




