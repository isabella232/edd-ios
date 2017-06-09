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

private let sharedDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}()

class SubscriptionsDetailViewController: SiteTableViewController {
    
    fileprivate enum CellType {
        case billingHeading
        case billing
        case productHeading
        case product
        case customerHeading
        case customer
        case renewalPaymentsHeading
        case renewalPayments
    }
    
    fileprivate var cells = [CellType]()

    var site: Site?
    var subscription: Subscriptions!
    
    var product: JSON?
    var customer: JSON?
    
    var productObject: Product?
    
    init(subscription: Subscriptions) {
        super.init(style: .plain)
        
        self.site = Site.activeSite()
        self.subscription = subscription
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        
        if let id = subscription.ID {
            title = NSLocalizedString("Subscription", comment: "") + " #" + String(describing: id)
            let titleLabel = ViewControllerTitleLabel()
            titleLabel.setTitle(NSLocalizedString("Subscription", comment: "") + " #" + String(describing: id))
            navigationItem.titleView = titleLabel
        }
        
        tableView.register(SubscriptionsDetailHeadingTableViewCell.self, forCellReuseIdentifier: "SubscriptionsDetailHeadingTableViewCell")
        tableView.register(SubscriptionsDetailBillingTableViewCell.self, forCellReuseIdentifier: "SubscriptionsDetailBillingTableViewCell")
        tableView.register(SubscriptionsDetailRenewalPaymentsTableViewCell.self, forCellReuseIdentifier: "SubscriptionsDetailRenewalPaymentsTableViewCell")
        tableView.register(SubscriptionsDetailProductTableViewCell.self, forCellReuseIdentifier: "SubscriptionsDetailProductTableViewCell")
        tableView.register(SubscriptionsDetailCustomerTableViewCell.self, forCellReuseIdentifier: "SubscriptionsDetailCustomerTableViewCell")
        
        cells = [.billingHeading, .billing, .productHeading, .product, .customerHeading, .customer]
        
        if let renewalPayments = subscription.renewalPayments {
            if renewalPayments.count > 0 {
                cells.append(.renewalPaymentsHeading)
                for _ in 1...renewalPayments.count {
                    cells.append(.renewalPayments)
                }
            }
        }
        
        networkOperations()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func networkOperations() {
        EDDAPIWrapper.sharedInstance.requestProducts(["product": "\(subscription.productId)" as AnyObject], success: { (json) in
            if let items = json["products"].array {
                self.product = items[0]
                
                let item = items[0]
                
                var stats: NSData?
                if Site.hasPermissionToViewReports() {
                    stats = NSKeyedArchiver.archivedData(withRootObject: item["stats"].dictionaryObject!) as NSData
                } else {
                    stats = nil
                }
                
                var files: NSData?
                var notes: String?
                if Site.hasPermissionToViewSensitiveData() {
                    if item["files"].arrayObject != nil {
                        files = NSKeyedArchiver.archivedData(withRootObject: item["files"].arrayObject!) as NSData
                    } else {
                        files = nil
                    }
                    
                    notes = item["notes"].stringValue
                } else {
                    files = nil
                    notes = nil
                }
                
                var hasVariablePricing = false
                if (item["pricing"].dictionary?.count)! > 1 {
                    hasVariablePricing = true
                }
                
                let pricing = NSKeyedArchiver.archivedData(withRootObject: item["pricing"].dictionaryObject!)
                
                self.productObject = Product.objectForData(AppDelegate.sharedInstance.managedObjectContext, content: item["info"]["content"].stringValue, createdDate: sharedDateFormatter.date(from: item["info"]["create_date"].stringValue)!, files: files! as Data, hasVariablePricing: hasVariablePricing as NSNumber, link: item["info"]["link"].stringValue, modifiedDate: sharedDateFormatter.date(from: item["info"]["modified_date"].stringValue)!, notes: notes, pid: item["info"]["id"].int64Value, pricing: pricing, stats: stats! as Data, status: item["info"]["status"].stringValue, thumbnail: item["info"]["thumbnail"].string, title: item["info"]["title"].stringValue, licensing: item["licensing"].dictionary as [String : AnyObject]?)
                
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
            }) { (error) in
                print(error)
        }
    }
    
    // MARK: Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if cells[indexPath.row] == CellType.product {
            guard let product = self.productObject else {
                return
            }
            
            navigationController?.pushViewController(ProductsDetailViewController(product: product), animated: true)
        }
        
        if cells[indexPath.row] == CellType.renewalPayments {
            guard let payments = subscription.renewalPayments else {
                return
            }
            
            navigationController?.pushViewController(SalesUncachedViewController(id: payments[indexPath.row - 7]["id"].int64Value), animated: true)
        }
        
        if cells[indexPath.row] == CellType.customer {
            navigationController?.pushViewController(CustomerOfflineViewController(email: subscription.customer["email"]!.stringValue), animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        switch cells[indexPath.row] {
            case .billingHeading:
                cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionsDetailHeadingTableViewCell", for: indexPath) as! SubscriptionsDetailHeadingTableViewCell
                (cell as! SubscriptionsDetailHeadingTableViewCell).configure(NSLocalizedString("Billing", comment: ""))
            case .billing:
                cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionsDetailBillingTableViewCell", for: indexPath) as! SubscriptionsDetailBillingTableViewCell
                (cell as! SubscriptionsDetailBillingTableViewCell).configure(subscription)
            case .productHeading:
                cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionsDetailHeadingTableViewCell", for: indexPath) as! SubscriptionsDetailHeadingTableViewCell
                (cell as! SubscriptionsDetailHeadingTableViewCell).configure(NSLocalizedString("Product", comment: ""))
            case .product:
                cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionsDetailProductTableViewCell", for: indexPath) as! SubscriptionsDetailProductTableViewCell
                (cell as! SubscriptionsDetailProductTableViewCell).configure(product)
            case .customerHeading:
                cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionsDetailHeadingTableViewCell", for: indexPath) as! SubscriptionsDetailHeadingTableViewCell
                (cell as! SubscriptionsDetailHeadingTableViewCell).configure(NSLocalizedString("Customer", comment: ""))
            case .customer:
                cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionsDetailCustomerTableViewCell", for: indexPath) as! SubscriptionsDetailCustomerTableViewCell
                (cell as! SubscriptionsDetailCustomerTableViewCell).configure(subscription.customer)
            case .renewalPaymentsHeading:
                cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionsDetailHeadingTableViewCell", for: indexPath) as! SubscriptionsDetailHeadingTableViewCell
                (cell as! SubscriptionsDetailHeadingTableViewCell).configure(NSLocalizedString("Renewal Payments", comment: ""))
            case .renewalPayments:
                cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionsDetailRenewalPaymentsTableViewCell", for: indexPath) as! SubscriptionsDetailRenewalPaymentsTableViewCell
                (cell as! SubscriptionsDetailRenewalPaymentsTableViewCell).configure(subscription.renewalPayments![indexPath.row-7])
        }
        
        return cell!
    }

}
