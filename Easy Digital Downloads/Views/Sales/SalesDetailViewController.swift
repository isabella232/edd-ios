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
        case ProductsHeading
        case Product
        case CustomerHeading
        case Customer
    }
    
    private var cells = [CellType]()
    
    var site: Site?
    var sale: Sale?
    var products: [AnyObject]?
    
    init(sale: Sale) {
        super.init(style: .Plain)
        
        self.site = Site.activeSite()
        self.sale = sale
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
        
        title = NSLocalizedString("Sale", comment: "") + " #" + "\(sale.sid)"
        
        tableView.registerClass(SalesDetailMetaTableViewCell.self, forCellReuseIdentifier: "SalesDetailMetaTableViewCell")
        tableView.registerClass(SalesDetailHeadingTableViewCell.self, forCellReuseIdentifier: "SalesDetailHeadingTableViewCell")
        tableView.registerClass(SalesDetailProductTableViewCell.self, forCellReuseIdentifier: "SalesDetailProductTableViewCell")
        tableView.registerClass(SalesDetailCustomerTableViewCell.self, forCellReuseIdentifier: "SalesDetailCustomerTableViewCell")
        
        cells = [.Meta, .ProductsHeading]
        
        products = (NSKeyedUnarchiver.unarchiveObjectWithData(sale.products)! as! [AnyObject])
        
        if products!.count == 1 {
            cells.append(.Product)
        } else {
            for _ in 1...products!.count {
                cells.append(.Product)
            }
        }

        cells.append(.CustomerHeading)
        cells.append(.Customer)
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        switch cells[indexPath.row] {
            case .Meta:
                cell = tableView.dequeueReusableCellWithIdentifier("SalesDetailMetaTableViewCell", forIndexPath: indexPath) as! SalesDetailMetaTableViewCell
                (cell as! SalesDetailMetaTableViewCell).configure(sale!)
            case .ProductsHeading:
                cell = tableView.dequeueReusableCellWithIdentifier("SalesDetailHeadingTableViewCell", forIndexPath: indexPath) as! SalesDetailHeadingTableViewCell
                (cell as! SalesDetailHeadingTableViewCell).configure("Products")
            case .Product:
                cell = tableView.dequeueReusableCellWithIdentifier("SalesDetailProductTableViewCell", forIndexPath: indexPath) as! SalesDetailProductTableViewCell
                (cell as! SalesDetailProductTableViewCell).configure(products![indexPath.row - 2])
            case .CustomerHeading:
                cell = tableView.dequeueReusableCellWithIdentifier("SalesDetailHeadingTableViewCell", forIndexPath: indexPath) as! SalesDetailHeadingTableViewCell
                (cell as! SalesDetailHeadingTableViewCell).configure("Customer")
            case .Customer:
                cell = tableView.dequeueReusableCellWithIdentifier("SalesDetailCustomerTableViewCell", forIndexPath: indexPath) as! SalesDetailCustomerTableViewCell
        }
        
        return cell!
    }

}
