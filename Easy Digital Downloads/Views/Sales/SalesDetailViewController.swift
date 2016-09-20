//
//  SalesDetailViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 06/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON

class SalesDetailViewController: SiteTableViewController {

    private enum CellType {
        case Meta
        case Product
        case Payment
        case Customer
    }
    
    private var cells = [CellType]()
    
    var site: Site?
    var sale: Sale?
    
    init(sale: Sale) {
        super.init(style: .Plain)
        
        self.site = Site.activeSite()
        self.sale = sale
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Table View Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    // MARK: Table View Delegate

}
