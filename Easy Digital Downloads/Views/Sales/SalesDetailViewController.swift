//
//  SalesDetailViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 06/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import AlamofireImage
import SwiftyJSON

private let sharedDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}()

class SalesDetailViewController: SiteTableViewController {

    private enum CellType {
        case Meta
        case ProductsHeading
        case Product
        case CustomerHeading
        case Customer
        case LicensesHeading
        case License
    }
    
    private var cells = [CellType]()
    
    var site: Site?
    var sale: Sale?
    var products: [AnyObject]?
    var licenses: [AnyObject]?
    var customer: JSON?
    
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
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(NSLocalizedString("Sale", comment: "") + " #" + "\(sale.sid)")
        navigationItem.titleView = titleLabel
        
        tableView.registerClass(SalesDetailMetaTableViewCell.self, forCellReuseIdentifier: "SalesDetailMetaTableViewCell")
        tableView.registerClass(SalesDetailHeadingTableViewCell.self, forCellReuseIdentifier: "SalesDetailHeadingTableViewCell")
        tableView.registerClass(SalesDetailProductTableViewCell.self, forCellReuseIdentifier: "SalesDetailProductTableViewCell")
        tableView.registerClass(SalesDetailCustomerTableViewCell.self, forCellReuseIdentifier: "SalesDetailCustomerTableViewCell")
        tableView.registerClass(SalesDetailLicensesTableViewCell.self, forCellReuseIdentifier: "SalesDetailLicensesTableViewCell")
        
        cells = [.Meta, .ProductsHeading]
        
        EDDAPIWrapper.sharedInstance.requestCustomers(["customer": sale.email], success: { json in
            let items = json["customers"].arrayValue
            self.customer = items[0]
            dispatch_async(dispatch_get_main_queue(), { 
                self.tableView.reloadData()
            })
            }) { (error) in
                print(error.localizedDescription)
        }
        
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
        
        if sale.licenses != nil {
            cells.append(.LicensesHeading)
            
            licenses = (NSKeyedUnarchiver.unarchiveObjectWithData(sale.licenses!)! as! [AnyObject])
            
            if licenses!.count == 1 {
                cells.append(.License)
            } else {
                for _ in 1...licenses!.count {
                    cells.append(.License)
                }
            }
        }
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if cells[indexPath.row] == CellType.Customer {
            guard let item = customer else {
                return
            }
            let customerObject = Customer.objectForData(AppDelegate.sharedInstance.managedObjectContext, displayName: item["info"]["display_name"].stringValue, email: item["info"]["email"].stringValue, firstName: item["info"]["first_name"].stringValue, lastName: item["info"]["last_name"].stringValue, totalDownloads: item["stats"]["total_downloads"].int64Value, totalPurchases: item["stats"]["total_purchases"].int64Value, totalSpent: item["stats"]["total_spent"].doubleValue, uid: item["info"]["user_id"].int64Value, username: item["username"].stringValue, dateCreated: sharedDateFormatter.dateFromString(item["info"]["date_created"].stringValue)!)
            navigationController?.pushViewController(CustomersDetailViewController(customer: customerObject), animated: true)
        }
        
        if cells[indexPath.row] == CellType.Product {
            let product: AnyObject = products![indexPath.row - 2]
            let id = product["id"] as! NSNumber
            navigationController?.pushViewController(ProductsOfflineViewController(id: id), animated: true)
        }
            
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
                (cell as! SalesDetailCustomerTableViewCell).configure(customer)
            case .LicensesHeading:
                cell = tableView.dequeueReusableCellWithIdentifier("SalesDetailHeadingTableViewCell", forIndexPath: indexPath) as! SalesDetailHeadingTableViewCell
                (cell as! SalesDetailHeadingTableViewCell).configure("Licenses")
            case .License:
                cell = tableView.dequeueReusableCellWithIdentifier("SalesDetailLicensesTableViewCell", forIndexPath: indexPath) as! SalesDetailLicensesTableViewCell
                (cell as! SalesDetailLicensesTableViewCell).configure(licenses![indexPath.row - 5 - (products?.count)!])
        }
        
        return cell!
    }

}
