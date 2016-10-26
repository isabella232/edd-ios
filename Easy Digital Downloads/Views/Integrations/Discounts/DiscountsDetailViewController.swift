//
//  DiscountsDetailViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 18/10/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON

private let sharedDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}()

class DiscountsDetailViewController: SiteTableViewController {

    private enum CellType {
        case MetaHeading
        case Meta
        case ProductRequirementsHeading
        case ProductRequirements
    }
    
    private var cells = [CellType]()
    
    var site: Site?
    var discount: Discounts?
    
    var fetchedProducts: [Product] = [Product]()
    
    init(discount: Discounts) {
        super.init(style: .Plain)
        
        self.site = Site.activeSite()
        self.discount = discount
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
        
        title = NSLocalizedString("Discount", comment: "") + " #" + "\(discount.ID)"
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(NSLocalizedString("Discount", comment: "") + " #" + "\(discount.ID)")
        navigationItem.titleView = titleLabel
        
        setupDataSource()
        networkOperations()
        
        tableView.registerClass(DiscountsDetailMetaTableViewCell.self, forCellReuseIdentifier: "DiscountsDetailMetaTableViewCell")
        tableView.registerClass(DiscountsDetailProductRequirementTableViewCell.self, forCellReuseIdentifier: "DiscountsDetailProductRequirementTableViewCell")
        tableView.registerClass(DiscountsDetailHeadingTableViewCell.self, forCellReuseIdentifier: "DiscountsDetailHeadingTableViewCell")
        
        cells = [.MetaHeading, .Meta]
        
        if let requirements = discount.productRequirements {
            cells.append(.ProductRequirementsHeading)
            
            if requirements.count == 1 {
                self.cells.append(.ProductRequirements)
            } else {
                for _ in 1...requirements.count {
                    self.cells.append(.ProductRequirements)
                }
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Private
    
    private func setupDataSource() {
        if let requirements = discount?.productRequirements {
            for item in requirements {
                if let product = Product.productForId(item.1.int64Value) {
                    self.fetchedProducts.append(product)
                } else {
                    EDDAPIWrapper.sharedInstance.requestProducts(["product" : item.1.stringValue], success: { (json) in
                        
                        }, failure: { (error) in
                            print(error)
                    })
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), { 
                self.tableView.reloadData()
            })
            
        }
    }
    
    private func networkOperations() {
        if let requirements = discount?.productRequirements {
            for item in requirements {
                EDDAPIWrapper.sharedInstance.requestProducts(["product" : item.1.stringValue], success: { (json) in
                    
                }, failure: { (error) in
                    print(error)
                })
            }
        }
    }
    
    // MARK: Table View Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: Table View Delegate
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        switch cells[indexPath.row] {
            case .MetaHeading:
                cell = tableView.dequeueReusableCellWithIdentifier("DiscountsDetailHeadingTableViewCell", forIndexPath: indexPath) as! DiscountsDetailHeadingTableViewCell
                (cell as! DiscountsDetailHeadingTableViewCell).configure("Meta")
            case .Meta:
                cell = tableView.dequeueReusableCellWithIdentifier("DiscountsDetailMetaTableViewCell", forIndexPath: indexPath) as! DiscountsDetailMetaTableViewCell
                (cell as! DiscountsDetailMetaTableViewCell).configure(discount!)
            case .ProductRequirementsHeading:
                cell = tableView.dequeueReusableCellWithIdentifier("DiscountsDetailHeadingTableViewCell", forIndexPath: indexPath) as! DiscountsDetailHeadingTableViewCell
                (cell as! DiscountsDetailHeadingTableViewCell).configure("Product Requirements")
            case .ProductRequirements:
                cell = tableView.dequeueReusableCellWithIdentifier("DiscountsDetailProductRequirementTableViewCell", forIndexPath: indexPath) as! DiscountsDetailProductRequirementTableViewCell
                if self.fetchedProducts.indices.contains(indexPath.row - 3) {
                    (cell as! DiscountsDetailProductRequirementTableViewCell).configure(self.fetchedProducts[indexPath.row - 3])
                } else {
                    (cell as! DiscountsDetailProductRequirementTableViewCell).configure(nil)
            }
                
        }
        
        return cell!
    }

}
