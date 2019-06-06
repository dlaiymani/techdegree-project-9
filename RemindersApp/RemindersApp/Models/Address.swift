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
    
    init(number: String?, street: String?, postalCode: String?, locality: String?, country: String?) {
        self.number = number
        self.street = street
        self.postalCode = postalCode
        self.locality = locality
        self.country = country
    }
}
