//
//  Coordinate.swift
//  RemindersApp
//
//  Created by davidlaiymani on 05/06/2019.
//  Copyright © 2019 davidlaiymani. All rights reserved.
//

import Foundation
import CoreLocation

// The coordinate type
struct Coordinate {
    let latitude: Double
    let longitude: Double
    
    init(location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
    }
    
     init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func isNotSet() -> Bool {
        if latitude == 0.0 && longitude == 0.0 {
            return true
        } else {
            return false
        }
    }
}
