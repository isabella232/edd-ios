//
//  SubscriptionsDetailViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 26/09/2016.
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

class SubscriptionsDetailViewController: SiteTableViewController {
    
    private enum CellType {
        case BillingHeading
        case Billing
        case ProductHeading
        case Product
        case CustomerHeading
        case Customer
        case RenewalPaymentsHeading
        case RenewalPayments
        case LicensingHeading
        case Licensing
    }
    
    private var cells = [CellType]()

    var site: Site?
    var subscription: Subscription?
    
    var product: JSON?
    var customer: JSON?
    
    var productObject: Product?
    
    init(subscription: Subscription) {
        super.init(style: .Plain)
        
        self.site = Site.activeSite()
        self.subscription = subscription
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
        
        title = NSLocalizedString("Subscription", comment: "") + " #" + "\(subscription.sid)"
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(NSLocalizedString("Subscription", comment: "") + " #" + "\(subscription.sid)")
        navigationItem.titleView = titleLabel
        
        tableView.registerClass(SubscriptionsDetailHeadingTableViewCell.self, forCellReuseIdentifier: "SubscriptionsDetailHeadingTableViewCell")
        tableView.registerClass(SubscriptionsDetailBillingTableViewCell.self, forCellReuseIdentifier: "SubscriptionsDetailBillingTableViewCell")
        tableView.registerClass(SubscriptionsDetailRenewalPaymentsTableViewCell.self, forCellReuseIdentifier: "SubscriptionsDetailRenewalPaymentsTableViewCell")
        tableView.registerClass(SubscriptionsDetailLicensingTableViewCell.self, forCellReuseIdentifier: "SubscriptionsDetailLicensingTableViewCell")
        tableView.registerClass(SubscriptionsDetailProductTableViewCell.self, forCellReuseIdentifier: "SubscriptionsDetailProductTableViewCell")
        tableView.registerClass(SubscriptionsDetailCustomerTableViewCell.self, forCellReuseIdentifier: "SubscriptionsDetailCustomerTableViewCell")
        
        cells = [.BillingHeading, .Billing, .ProductHeading, .Product, .CustomerHeading, .Customer, .RenewalPaymentsHeading, .RenewalPayments, .LicensingHeading, .Licensing]
        
        networkOperations()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func networkOperations() {
        guard let subscription_ = subscription else {
            return
        }

        EDDAPIWrapper.sharedInstance.requestProducts(["product": "\(subscription_.productID)"], success: { (json) in
            if let items = json["products"].array {
                self.product = items[0]
                
                let item = items[0]
                
                var stats: NSData?
                if Site.hasPermissionToViewReports() {
                    stats = NSKeyedArchiver.archivedDataWithRootObject(item["stats"].dictionaryObject!)
                } else {
                    stats = nil
                }
                
                var files: NSData?
                var notes: String?
                if Site.hasPermissionToViewSensitiveData() {
                    if item["files"].arrayObject != nil {
                        files = NSKeyedArchiver.archivedDataWithRootObject(item["files"].arrayObject!)
                    } else {
                        files = nil
                    }
                    
                    notes = item["notes"].stringValue
                } else {
                    files = nil
                    notes = nil
                }
                
                var hasVariablePricing = false
                if item["pricing"].dictionary?.count > 1 {
                    hasVariablePricing = true
                }
                
                let pricing = NSKeyedArchiver.archivedDataWithRootObject(item["pricing"].dictionaryObject!)
                
                self.productObject = Product.objectForData(AppDelegate.sharedInstance.managedObjectContext, content: item["info"]["content"].stringValue, createdDate: sharedDateFormatter.dateFromString(item["info"]["create_date"].stringValue)!, files: files, hasVariablePricing: hasVariablePricing, link: item["info"]["link"].stringValue, modifiedDate: sharedDateFormatter.dateFromString(item["info"]["modified_date"].stringValue)!, notes: notes, pid: item["info"]["id"].int64Value, pricing: pricing, stats: stats, status: item["info"]["status"].stringValue, thumbnail: item["info"]["thumbnail"].stringValue, title: item["info"]["title"].stringValue, licensing: item["licensing"].dictionaryObject)
                
                dispatch_async(dispatch_get_main_queue(), { 
                    self.tableView.reloadData()
                })
            }
            }) { (error) in
                print(error)
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
        if cells[indexPath.row] == CellType.Product {
            guard let product = self.productObject else {
                return
            }
            
            navigationController?.pushViewController(ProductsDetailViewController(product: product), animated: true)
        }
        
        if cells[indexPath.row] == CellType.Customer {
//            guard let customer = self.customer else {
//                return
//            }
            
            navigationController?.pushViewController(CustomerOfflineViewController(email: (subscription!.customer["email"] as? String)!), animated: true)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: Table View Delegate
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        switch cells[indexPath.row] {
            case .BillingHeading:
                cell = tableView.dequeueReusableCellWithIdentifier("SubscriptionsDetailHeadingTableViewCell", forIndexPath: indexPath) as! SubscriptionsDetailHeadingTableViewCell
                (cell as! SubscriptionsDetailHeadingTableViewCell).configure(NSLocalizedString("Billing", comment: ""))
            case .Billing:
                cell = tableView.dequeueReusableCellWithIdentifier("SubscriptionsDetailBillingTableViewCell", forIndexPath: indexPath) as! SubscriptionsDetailBillingTableViewCell
                (cell as! SubscriptionsDetailBillingTableViewCell).configure(subscription!)
            case .ProductHeading:
                cell = tableView.dequeueReusableCellWithIdentifier("SubscriptionsDetailHeadingTableViewCell", forIndexPath: indexPath) as! SubscriptionsDetailHeadingTableViewCell
                (cell as! SubscriptionsDetailHeadingTableViewCell).configure(NSLocalizedString("Product", comment: ""))
            case .Product:
                cell = tableView.dequeueReusableCellWithIdentifier("SubscriptionsDetailProductTableViewCell", forIndexPath: indexPath) as! SubscriptionsDetailProductTableViewCell
                (cell as! SubscriptionsDetailProductTableViewCell).configure(product)
            case .CustomerHeading:
                cell = tableView.dequeueReusableCellWithIdentifier("SubscriptionsDetailHeadingTableViewCell", forIndexPath: indexPath) as! SubscriptionsDetailHeadingTableViewCell
                (cell as! SubscriptionsDetailHeadingTableViewCell).configure(NSLocalizedString("Customer", comment: ""))
            case .Customer:
                cell = tableView.dequeueReusableCellWithIdentifier("SubscriptionsDetailCustomerTableViewCell", forIndexPath: indexPath) as! SubscriptionsDetailCustomerTableViewCell
                (cell as! SubscriptionsDetailCustomerTableViewCell).configure(subscription!.customer)
            case .RenewalPaymentsHeading:
                cell = tableView.dequeueReusableCellWithIdentifier("SubscriptionsDetailHeadingTableViewCell", forIndexPath: indexPath) as! SubscriptionsDetailHeadingTableViewCell
                (cell as! SubscriptionsDetailHeadingTableViewCell).configure(NSLocalizedString("Renewal Payments", comment: ""))
            case .RenewalPayments:
                cell = tableView.dequeueReusableCellWithIdentifier("SubscriptionsDetailRenewalPaymentsTableViewCell", forIndexPath: indexPath) as! SubscriptionsDetailRenewalPaymentsTableViewCell
            case .LicensingHeading:
                cell = tableView.dequeueReusableCellWithIdentifier("SubscriptionsDetailHeadingTableViewCell", forIndexPath: indexPath) as! SubscriptionsDetailHeadingTableViewCell
                (cell as! SubscriptionsDetailHeadingTableViewCell).configure(NSLocalizedString("Licensing", comment: ""))
            case .Licensing:
                cell = tableView.dequeueReusableCellWithIdentifier("SubscriptionsDetailLicensingTableViewCell", forIndexPath: indexPath) as! SubscriptionsDetailLicensingTableViewCell
        }
        
        return cell!
    }

}
