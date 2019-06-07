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
    @IBOutlet weak var tableView: UITableView!
    
    lazy var locationManager: LocationManager = {
        return LocationManager(delegate: self, permissionsDelegate: nil)
    }()
    
    var locationDescription = ""
    var eventType = false
    
    let searchController = UISearchController(searchResultsController: nil)
    
    let dataSource = SearchAddressResultsDataSource()
    var request = MKLocalSearch.Request()
    var search: MKLocalSearch?
    
    // Find an address from coordinates
    var geocoder = CLGeocoder()
    var coordinate: Coordinate? { // When coordinates are set the perform geocoding
        didSet {
            if let coordinate = coordinate {
                let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                geocoder.reverseGeocodeLocation(location) { placemarks, error in
                    if let error = error {
                        let alertError = AlertError(error: .unableToFindLocation, on: self)
                    } else {
                        if let placemarks = placemarks, let placemark = placemarks.first, let name = placemark.name, let locality = placemark.locality, let adminArea = placemark.administrativeArea {
                            self.locationDescription = "\(name), \(locality)"
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
        mapView.delegate = self
        self.tableView.dataSource = dataSource
        self.tableView.delegate = self
        
        
        setupSearchBar()
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = .black
        if let coordinate = coordinate {
            if !coordinate.isNotSet() {
                adjustMap(with: coordinate)
            }
        }
        
        if eventType == false {
            alertingSegmentedControl.selectedSegmentIndex = 0
        } else {
            alertingSegmentedControl.selectedSegmentIndex = 1

        }
        
    }
    
    func setupSearchBar() {
       
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.placeholder = "Search for places"
        self.navigationItem.searchController = searchController
    }
    
    // Check permission or request the current location
    override func viewDidAppear(_ animated: Bool) {
        if isAuthorized {
        //    locationManager.requestLocation()
        } else {
            checkPermissions()
        }
    }
    
    func checkPermissions() {
        do {
            try locationManager.requestLocationAuthorization()
        } catch LocationError.disallowedByUser {
            self.showAlert(withTitle: "ReminderApp needs your location data", message: "Please, see your settings configuration")
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
    

    // MARK: - Navigation
    // Back to Detail Controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SaveLocationSegue" {
            let detailViewController = segue.destination as! DetailController
            if let coordinate = coordinate {
                detailViewController.coordinate = coordinate
                detailViewController.locationDescription = locationDescription
                if alertingSegmentedControl.selectedSegmentIndex == 0 {
                    detailViewController.eventType = false
                } else {
                    detailViewController.eventType = true
                }
                detailViewController.locationManager = self.locationManager
            }
        }
    }
}


// MARK: - UITableViewDelegate
extension LocationController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.searchController.searchBar.resignFirstResponder()
        let mapItem = dataSource.object(at: indexPath)
        let coordinate = Coordinate(latitude: mapItem.placemark.coordinate.latitude, longitude: mapItem.placemark.coordinate.longitude)
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.removeOverlays(self.mapView.overlays)
        self.coordinate = coordinate
        self.adjustMap(with: coordinate)
    }
    
}


// MARK: - Location Manager Delegate
extension LocationController: LocationManagerDelegate {
    func obtainedCoordinates(_ coordinate: Coordinate) {
        self.coordinate = coordinate
        adjustMap(with: coordinate)
    }
    
    func failedWithError(_ error: LocationError) {
        mapView.isHidden = true
        let alertError = AlertError(error: error, on: self)
        alertError.displayAlert()
    }
}

// MARK: - MapKit
extension LocationController {
    // Adjust the map around the current location and display an annotation at this location
    func adjustMap(with coordinate: Coordinate) {
        
        let coordinate2D = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let region = MKCoordinateRegion.init(center: coordinate2D, latitudinalMeters: 500, longitudinalMeters: 500)
        
        mapView.removeOverlays(mapView.overlays)
        mapView.setRegion(region, animated: true)
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
        mapView.addAnnotation(myAnnotation)
        mapView?.addOverlay(MKCircle(center: coordinate2D, radius: CLLocationDistance(exactly: 50.0)!))
        
    }
    

}

// MARK: - MapView Delegate
extension LocationController: MKMapViewDelegate {

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


// MARK: SearchController management

extension LocationController: UISearchResultsUpdating, UITextFieldDelegate {
    // When the search controller is activated i.e. the user enters a text,
    // we change the fetchResultController to retreive the corresponding notes
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchTerm = searchController.searchBar.text else { return }

        if !searchTerm.isEmpty {
            
            search?.cancel()
            request.naturalLanguageQuery = searchTerm
            request.region = self.mapView.region
            
            search = MKLocalSearch(request: request)
            
            search!.start { (responses, error) in
                if let responses = responses {
                    DispatchQueue.main.async {
                        self.dataSource.update(with: responses.mapItems)
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
}



// SearchBar delegate
extension LocationController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dataSource.update(with: [])
        tableView.reloadData()
    }
    
    // When the user enter some text, the quick note view is dismissed
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //tableView.reloadData()
    }
    
    // Cross button tapped
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       
        if searchText == "" {
            dataSource.update(with: [])
            tableView.reloadData()
        }
    }
}
