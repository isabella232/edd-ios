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
        
        title = NSLocalizedString("Sale", comment: "") + " #" + "\(sale.sid)"
        
        tableView.registerClass(SalesDetailMetaTableViewCell.self, forCellReuseIdentifier: "SalesDetailMetaTableViewCell")
        tableView.registerClass(SalesDetailProductTableViewCell.self, forCellReuseIdentifier: "SalesDetailProductTableViewCell")
        tableView.registerClass(SalesDetailPaymentTableViewCell.self, forCellReuseIdentifier: "SalesDetailPaymentTableViewCell")
        tableView.registerClass(SalesDetailCustomerTableViewCell.self, forCellReuseIdentifier: "SalesDetailCustomerTableViewCell")
        
        cells = [.Meta, .Product, .Payment, .Customer]
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
            case .Product:
                cell = tableView.dequeueReusableCellWithIdentifier("SalesDetailProductTableViewCell", forIndexPath: indexPath) as! SalesDetailProductTableViewCell
            case .Payment:
                cell = tableView.dequeueReusableCellWithIdentifier("SalesDetailPaymentTableViewCell", forIndexPath: indexPath) as! SalesDetailPaymentTableViewCell
            case .Customer:
                cell = tableView.dequeueReusableCellWithIdentifier("SalesDetailCustomerTableViewCell", forIndexPath: indexPath) as! SalesDetailCustomerTableViewCell
        }
        
        return cell!
    }

}
