//
//  Address.swift
//  RemindersApp
//
//  Created by davidlaiymani on 06/06/2019.
//  Copyright © 2019 davidlaiymani. All rights reserved.
//

import Foundation

class Address {
    
    var number: String?
    var street: String?
    var postalCode: String?
    var locality: String?
    var country: String?
    var name: String?
    var coordinate: Coordinate?
    
    init(number: String?, street: String?, postalCode: String?, locality: String?, country: String?, name: String?, coordinate: Coordinate?) {
        self.number = number
        self.street = street
        self.postalCode = postalCode
        self.locality = locality
        self.country = country
        self.name = name
        self.coordinate = coordinate
    }
    
    func addressString() -> String {
        
        var addressString = ""
        if self.name != nil {
            addressString += "\(self.name!) "
        }
//        if self.number != nil {
//            addressString += "\(self.number!) "
//        }
        
//        if self.street != nil {
//            addressString += "\(self.street!)"
//        }
        
        return addressString
    }
    
    func completeAddressString() -> String {
        
        var addressString = ""
        if self.number != nil {
            addressString += "\(self.number!) "
        }
        
        if self.street != nil {
            addressString += "\(self.street!) "
        }
        
        if self.postalCode != nil {
            addressString += "\(self.postalCode!) "
        }
        
        if self.locality != nil {
            addressString += "\(self.locality!) "
        }
        
        if self.country != nil {
            addressString += "\(self.country!) "
        }
        
        
        return addressString
    }
    
    
}
