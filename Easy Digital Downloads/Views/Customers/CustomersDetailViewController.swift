//
//  CustomersDetailViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 20/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import SwiftyJSON

class CustomersDetailViewController: SiteTableViewController {

    private enum CellType {
        case Profile
        case Stats
        case Heading
    }
    
    private var cells = [CellType]()
    
    var site: Site?
    var customer: Customer?
    var recentSales: [JSON]?
    
    init(customer: Customer) {
        super.init(style: .Plain)
        
        self.site = Site.activeSite()
        self.customer = customer
        
        title = customer.displayName
        
        view.backgroundColor = .EDDGreyColor()
        
        networkOperations()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
        
        tableView.registerClass(CustomerProfileTableViewCell.self, forCellReuseIdentifier: "CustomerProfileTableViewCell")
        tableView.registerClass(CustomerStatsTableViewCell.self, forCellReuseIdentifier: "CustomerStatsTableViewCell")
        tableView.registerClass(CustomerDetailHeadingTableViewCell.self, forCellReuseIdentifier: "CustomerHeadingTableViewCell")
        tableView.registerClass(CustomerRecentSaleTableViewCell.self, forCellReuseIdentifier: "CustomerRecentSaleTableViewCell")
        
        cells = [.Profile, .Stats, .Heading]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func networkOperations() {
        guard customer != nil else {
            return
        }
        
        EDDAPIWrapper.sharedInstance.requestSales(["email" : customer!.email], success: { (json) in
            if let items = json["sales"].array {
                self.recentSales = items
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
            }) { (error) in
                fatalError()
        }
    }
    
    // MARK: Table View Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let salesCount = recentSales?.count ?? 0
        return cells.count + salesCount
    }
    
    // MARK: Table View Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        if indexPath.row < 3 {
            switch(cells[indexPath.row]) {
                case .Profile:
                    cell = tableView.dequeueReusableCellWithIdentifier("CustomerProfileTableViewCell", forIndexPath: indexPath) as! CustomerProfileTableViewCell
                    (cell as! CustomerProfileTableViewCell).configure(customer!)
                case .Stats:
                    cell = tableView.dequeueReusableCellWithIdentifier("CustomerStatsTableViewCell", forIndexPath: indexPath) as! CustomerStatsTableViewCell
                    (cell as! CustomerStatsTableViewCell).configure(customer!)
                case .Heading:
                    cell = tableView.dequeueReusableCellWithIdentifier("CustomerHeadingTableViewCell", forIndexPath: indexPath) as! CustomerDetailHeadingTableViewCell
                    (cell as! CustomerDetailHeadingTableViewCell).configure("Recent Sales")
            }
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("CustomerRecentSaleTableViewCell", forIndexPath: indexPath) as! CustomerRecentSaleTableViewCell
            (cell as! CustomerRecentSaleTableViewCell).configure(recentSales![indexPath.row - 3])
        }
        
        return cell!
    }
    
}
