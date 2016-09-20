//
//  CustomersDetailViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 20/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

class CustomersDetailViewController: SiteTableViewController {

    private enum CellType {
        case Meta
        case Product
        case Payment
        case Customer
    }
    
    var site: Site?
    var customer: Customer?
    
    init(customer: Customer) {
        super.init(style: .Plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func networkOperations() {
        
    }
    
}
