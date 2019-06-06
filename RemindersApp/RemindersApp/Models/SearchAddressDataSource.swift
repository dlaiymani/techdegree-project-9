//
//  SearchAddressDataSource.swift
//  RemindersApp
//
//  Created by davidlaiymani on 06/06/2019.
//  Copyright © 2019 davidlaiymani. All rights reserved.
//

import Foundation
import UIKit


class SearchAddressResultsDataSource: NSObject, UITableViewDataSource {
    
    private var data = [Address]()
    
    override init() {
        super.init()
    }
    
    // MARK: Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath)
        
        let address = object(at: indexPath)
        cell.textLabel?.text = address.addressString()
        cell.detailTextLabel?.text = address.completeAddressString()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Locality"
        default: return nil
        }
    }
    
    // MARK: Helpers
    
    func object(at indexPath: IndexPath) -> Address {
        return data[indexPath.row]
    }
    
    func update(with data: [Address]) {
        self.data = data
    }
    
    func update(_ object: Address, at indexPath: IndexPath) {
        data[indexPath.row] = object
    }
    
}
