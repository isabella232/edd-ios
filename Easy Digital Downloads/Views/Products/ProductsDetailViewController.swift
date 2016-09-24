//
//  ProductsDetailViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 23/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON

class ProductsDetailViewController: SiteTableViewController {

    private enum CellType {
        case InfoHeading
//        case Info
        case StatsHeading
//        case Stats
        case PricingHeading
//        case Pricing
//        case NotesHeading
//        case Notes
//        case LicensingHeading
//        case Licensing
    }
    
    private var cells = [CellType]()
    
    var site: Site?
    var product: Product?
    var fetchedProduct: [JSON]?
    
    init(product: Product) {
        super.init(style: .Plain)
        
        self.site = Site.activeSite()
        self.product = product
        
        title = product.title
        
        view.backgroundColor = .EDDGreyColor()
        
        networkOperations()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.registerClass(ProductsDetailHeadingTableViewCell.self, forCellReuseIdentifier: "ProductHeadingTableViewCell")
        
        cells = [.InfoHeading, .StatsHeading, .PricingHeading]
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Private
    
    private func networkOperations() {
        guard product != nil else {
            return
        }
        
        EDDAPIWrapper.sharedInstance.requestProducts(["product": "\(product!.pid)"], success: { (json) in
            if let items = json["products"].array {
                self.fetchedProduct = items
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
        return cells.count
    }
    
    // MARK: Table View Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        switch(cells[indexPath.row]) {
            case .InfoHeading:
                cell = tableView.dequeueReusableCellWithIdentifier("ProductHeadingTableViewCell", forIndexPath: indexPath) as! ProductsDetailHeadingTableViewCell
                (cell as! ProductsDetailHeadingTableViewCell).configure("Info")
            case .StatsHeading:
                cell = tableView.dequeueReusableCellWithIdentifier("ProductHeadingTableViewCell", forIndexPath: indexPath) as! ProductsDetailHeadingTableViewCell
                (cell as! ProductsDetailHeadingTableViewCell).configure("Stats")
            case .PricingHeading:
                cell = tableView.dequeueReusableCellWithIdentifier("ProductHeadingTableViewCell", forIndexPath: indexPath) as! ProductsDetailHeadingTableViewCell
                (cell as! ProductsDetailHeadingTableViewCell).configure("Pricing")
        }
        
        return cell!
    }
    
}
