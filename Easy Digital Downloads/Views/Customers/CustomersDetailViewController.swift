//
//  CustomersDetailViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 20/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import SwiftyJSON

private let sharedDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}()

class CustomersDetailViewController: SiteTableViewController {

    var managedObjectContext: NSManagedObjectContext!
    
    fileprivate enum CellType {
        case profile
        case stats
        case salesHeading
        case sales
        case subscriptionsHeading
        case subscriptions
    }
    
    fileprivate var cells = [CellType]()
    
    var site: Site?
    var customer: Customer?
    var recentSales: [JSON]?
    var recentSubscriptions: [JSON]?
    
    init(customer: Customer) {
        super.init(style: .plain)
        
        self.site = Site.activeSite()
        self.customer = customer
        self.managedObjectContext = AppDelegate.sharedInstance.managedObjectContext
        
        title = customer.displayName
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle((customer.displayName.characters.count == 0 ? customer.email : customer.displayName))
        navigationItem.titleView = titleLabel
        
        view.backgroundColor = .EDDGreyColor()
        
        networkOperations()
        
        let uiBusy = UIActivityIndicatorView(activityIndicatorStyle: .white)
        uiBusy.hidesWhenStopped = true
        uiBusy.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: uiBusy)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        
        tableView.register(CustomerProfileTableViewCell.self, forCellReuseIdentifier: "CustomerProfileTableViewCell")
        tableView.register(CustomerStatsTableViewCell.self, forCellReuseIdentifier: "CustomerStatsTableViewCell")
        tableView.register(CustomerDetailHeadingTableViewCell.self, forCellReuseIdentifier: "CustomerHeadingTableViewCell")
        tableView.register(CustomerRecentSaleTableViewCell.self, forCellReuseIdentifier: "CustomerRecentSaleTableViewCell")
        tableView.register(CustomerDetailSubscriptionTableViewCell.self, forCellReuseIdentifier: "CustomerSubscriptionTableViewCell")
        
        cells = [.profile, .stats]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func networkOperations() {
        SessionManager.default.session.getAllTasks { (tasks) in
            tasks.forEach({ $0.cancel() })
        }
        
        guard customer != nil else {
            return
        }
        
        let customerRecord = Customer.fetchSingleObjectInContext(AppDelegate.sharedInstance.managedObjectContext) { (request) in
            request.predicate = Customer.predicateForId(self.customer!.uid)
            request.fetchLimit = 1
            }!
        
        EDDAPIWrapper.sharedInstance.requestCustomers(["customer" : customer!.email as AnyObject], success: { (json) in
            if let items = json["customers"].array {
                let item = items[0]
                
                customerRecord.setValue(item["info"]["display_name"].stringValue, forKey: Customer.Keys.DisplayName.rawValue)
                customerRecord.setValue(item["info"]["first_name"].stringValue, forKey: Customer.Keys.FirstName.rawValue)
                customerRecord.setValue(item["info"]["last_name"].stringValue, forKey: Customer.Keys.LastName.rawValue)
                customerRecord.setValue(NSNumber(value: item["stats"]["total_downloads"].int64Value), forKey: Customer.Keys.TotalDownloads.rawValue)
                customerRecord.setValue(NSNumber(value: item["stats"]["total_purchases"].int64Value), forKey: Customer.Keys.TotalPurchases.rawValue)
                customerRecord.setValue(item["stats"]["total_spent"].doubleValue, forKey: Customer.Keys.TotalSpent.rawValue)
                
                DispatchQueue.main.async(execute: {
                    do {
                        try AppDelegate.sharedInstance.managedObjectContext.save()
                        self.tableView.reloadData()
                        
                        self.navigationItem.rightBarButtonItem = nil
                    } catch {
                        print("Unable to save context")
                    }
                })
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        EDDAPIWrapper.sharedInstance.requestSales(["email" : customer!.email as AnyObject], success: { (json) in
            if let items = json["sales"].array {
                self.cells.append(.salesHeading)
                self.recentSales = items
                for _ in 1...items.count {
                    self.cells.append(.sales)
                }
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
            }) { (error) in
                print(error.localizedDescription)
        }
        
        if (Site.activeSite().hasRecurring != nil) {
            EDDAPIWrapper.sharedInstance.requestSubscriptions(["customer" : customer!.email as AnyObject], success: { (json) in
                if let items = json["subscriptions"].array {
                    self.cells.append(.subscriptionsHeading)
                    self.recentSubscriptions = items
                    for _ in 1...items.count {
                        self.cells.append(.subscriptions)
                    }
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                }
                }) { (error) in
                    print(error.localizedDescription)
            }
        }
    }
    
    // MARK: Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if cells[indexPath.row] == CellType.sales {
            var offset = 0
            if cells[2] == CellType.subscriptionsHeading {
                offset = indexPath.row - (recentSubscriptions?.count)! - 4
                
            } else {
                offset = indexPath.row - 3
            }
            
            let item = recentSales![offset]
            
            let sale = Sales(ID: item["ID"].int64Value, transactionId: item["transaction_id"].stringValue, key: item["key"].stringValue, subtotal: item["subtotal"].doubleValue, tax: item["tax"].double, fees: item["fees"].array, total: item["total"].doubleValue, gateway: item["gateway"].stringValue, email: item["email"].stringValue, date: sharedDateFormatter.date(from: item["date"].stringValue), discounts: item["discounts"].dictionary, products: item["products"].arrayValue, licenses: item["licenses"].array)
            
            navigationController?.pushViewController(SalesDetailViewController(sale: sale), animated: true)
        }
        
        if cells[indexPath.row] == CellType.subscriptions {
            var offset = 0
            if cells[2] == CellType.salesHeading {
                offset = indexPath.row - (recentSales?.count)! - 4
                
            } else {
                offset = indexPath.row - 3
            }
            
            let item = recentSubscriptions![offset]
            
            let subscription = Subscriptions(ID: item["info"]["id"].int64Value, customerId: item["info"]["customer_id"].int64Value, period: item["info"]["period"].stringValue, initialAmount: item["info"]["initial_amount"].doubleValue, recurringAmount: item["info"]["recurring_amount"].doubleValue, billTimes: item["info"]["bill_times"].int64Value, transactionId: item["info"]["transaction_id"].stringValue, parentPaymentId: item["info"]["parent_payment_id"].int64Value, productId: item["info"]["product_id"].int64Value, created: sharedDateFormatter.date(from: item["info"]["created"].stringValue), expiration: sharedDateFormatter.date(from: item["info"]["expiration"].stringValue), status: item["info"]["status"].stringValue, profileId: item["info"]["profile_id"].stringValue, gateway: item["info"]["gateway"].stringValue, customer: item["info"]["customer"].dictionaryValue, renewalPayments: item["payments"].array)
            
            navigationController?.pushViewController(SubscriptionsDetailViewController(subscription: subscription), animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        switch(cells[indexPath.row]) {
            case .profile:
                cell = tableView.dequeueReusableCell(withIdentifier: "CustomerProfileTableViewCell", for: indexPath) as! CustomerProfileTableViewCell
                (cell as! CustomerProfileTableViewCell).configure(customer!)
            case .stats:
                cell = tableView.dequeueReusableCell(withIdentifier: "CustomerStatsTableViewCell", for: indexPath) as! CustomerStatsTableViewCell
                (cell as! CustomerStatsTableViewCell).configure(customer!)
            case .salesHeading:
                cell = tableView.dequeueReusableCell(withIdentifier: "CustomerHeadingTableViewCell", for: indexPath) as! CustomerDetailHeadingTableViewCell
                (cell as! CustomerDetailHeadingTableViewCell).configure("Recent Sales")
            case .sales:
                cell = tableView.dequeueReusableCell(withIdentifier: "CustomerRecentSaleTableViewCell", for: indexPath) as! CustomerRecentSaleTableViewCell
                var offset = 0
                if cells[2] == CellType.subscriptionsHeading {
                    offset = indexPath.row - (recentSubscriptions?.count)! - 4
                    
                } else {
                    offset = indexPath.row - 3
                }
                (cell as! CustomerRecentSaleTableViewCell).configure(recentSales![offset])
            case .subscriptionsHeading:
                cell = tableView.dequeueReusableCell(withIdentifier: "CustomerHeadingTableViewCell", for: indexPath) as! CustomerDetailHeadingTableViewCell
                (cell as! CustomerDetailHeadingTableViewCell).configure("Recent Subscriptions")
            case .subscriptions:
                cell = tableView.dequeueReusableCell(withIdentifier: "CustomerSubscriptionTableViewCell", for: indexPath) as! CustomerDetailSubscriptionTableViewCell
                var offset = 0
                if cells[2] == CellType.salesHeading {
                    offset = indexPath.row - (recentSales?.count)! - 4
                    
                } else {
                    offset = indexPath.row - 3
                }
                (cell as! CustomerDetailSubscriptionTableViewCell).configure(recentSubscriptions![offset])
        }
        
        return cell!
    }
    
}
