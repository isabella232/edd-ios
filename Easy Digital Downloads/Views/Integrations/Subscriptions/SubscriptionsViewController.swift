//
//  SubscriptionsViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 26/08/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON
import Haneke

private let sharedDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}()

public struct Subscriptions {
    var ID: Int64!
    var customerId: Int64!
    var period: String!
    var initialAmount: Double!
    var recurringAmount: Double!
    var billTimes: Int64!
    var transactionId: String?
    var parentPaymentId: Int64!
    var productId: Int64!
    var created: Date!
    var expiration: Date!
    var status: String!
    var profileId: String!
    var gateway: String!
    var customer: [String: SwiftyJSON.JSON]!
    var renewalPayments: [SwiftyJSON.JSON]?
}

class SubscriptionsViewController: SiteTableViewController {

    var managedObjectContext: NSManagedObjectContext!
    
    typealias JSON = SwiftyJSON.JSON
    
    var site: Site?
    var subscriptions: JSON?
    let sharedCache = Shared.dataCache
    
    var operation = false
    
    var subscriptionObjects = [Subscriptions]()
    var filteredSubscriptionObjects = [Subscriptions]()
    
    var hasMoreSubscriptions: Bool = true {
        didSet {
            if (!hasMoreSubscriptions) {
                activityIndicatorView.stopAnimating()
            } else {
                activityIndicatorView.startAnimating()
            }
        }
    }
    
    let sharedDefaults: UserDefaults = UserDefaults(suiteName: "group.easydigitaldownloads.EDDSalesTracker")!
    
    var lastDownloadedPage = 1
    
    init(site: Site) {
        super.init(style: .plain)
        
        self.site = site
        self.managedObjectContext = AppDelegate.sharedInstance.managedObjectContext
        
        title = NSLocalizedString("Subscriptions", comment: "Subscriptions title")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 85.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(NSLocalizedString("Subscriptions", comment: "Subscriptions title"))
        navigationItem.titleView = titleLabel
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        networkOperations()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sharedCache.fetch(key: Site.activeSite().uid! + "-Subscriptions").onSuccess({ result in
            let json = JSON.convertFromData(result)! as JSON
            self.subscriptions = json
            
            if let items = json["subscriptions"].array {
                for item in items {
                    self.subscriptionObjects.append(Subscriptions(ID: item["info"]["id"].int64Value, customerId: item["info"]["customer_id"].int64Value, period: item["info"]["period"].stringValue, initialAmount: item["info"]["initial_amount"].doubleValue, recurringAmount: item["info"]["recurring_amount"].doubleValue, billTimes: item["info"]["bill_times"].int64Value, transactionId: item["info"]["transaction_id"].stringValue, parentPaymentId: item["info"]["parent_payment_id"].int64Value, productId: item["info"]["product_id"].int64Value, created: sharedDateFormatter.dateFromString(item["info"]["created"].stringValue), expiration: sharedDateFormatter.dateFromString(item["info"]["expiration"].stringValue), status: item["info"]["status"].stringValue, profileId: item["info"]["profile_id"].stringValue, gateway: item["info"]["gateway"].stringValue, customer: item["info"]["customer"].dictionaryValue, renewalPayments: item["payments"].array))
                }
            }
            
            self.subscriptionObjects.sortInPlace({ $0.created.compare($1.created) == NSComparisonResult.OrderedDescending })
            self.filteredSubscriptionObjects = self.subscriptionObjects
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        })
        
        setupInfiniteScrollView()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    // MARK: Network Operations
    
    fileprivate func networkOperations() {
        operation = true
        
        EDDAPIWrapper.sharedInstance.requestSubscriptions([ : ], success: { (json) in
            self.sharedCache.set(value: json.asData(), key: Site.activeSite().uid! + "-Subscriptions")
            
            self.subscriptionObjects.removeAll(keepCapacity: false)
            
            if let items = json["subscriptions"].array {
                for item in items {
                    self.subscriptionObjects.append(Subscriptions(ID: item["info"]["id"].int64Value, customerId: item["info"]["customer_id"].int64Value, period: item["info"]["period"].stringValue, initialAmount: item["info"]["initial_amount"].doubleValue, recurringAmount: item["info"]["recurring_amount"].doubleValue, billTimes: item["info"]["bill_times"].int64Value, transactionId: item["info"]["transaction_id"].stringValue, parentPaymentId: item["info"]["parent_payment_id"].int64Value, productId: item["info"]["product_id"].int64Value, created: sharedDateFormatter.dateFromString(item["info"]["created"].stringValue), expiration: sharedDateFormatter.dateFromString(item["info"]["expiration"].stringValue), status: item["info"]["status"].stringValue, profileId: item["info"]["profile_id"].stringValue, gateway: item["info"]["gateway"].stringValue, customer: item["info"]["customer"].dictionaryValue, renewalPayments: item["payments"].array))
                }
                
                if items.count < 10 {
                    self.hasMoreSubscriptions = false
                    dispatch_async(dispatch_get_main_queue(), {
                        self.activityIndicatorView.stopAnimating()
                    })
                }
            }
            
            self.subscriptionObjects.sortInPlace({ $0.created.compare($1.created) == NSComparisonResult.OrderedDescending })
            self.filteredSubscriptionObjects = self.subscriptionObjects
            
            dispatch_async(dispatch_get_main_queue(), { 
                self.tableView.reloadData()
            })
            
            self.updateLastDownloadedPage()
            
            self.operation = false
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    fileprivate func requestNextPage() {
        operation = true
        
        EDDAPIWrapper.sharedInstance.requestSubscriptions([ "page": lastDownloadedPage ], success: { (json) in
            if let items = json["subscriptions"].array {
                if items.count == 10 {
                    self.hasMoreSubscriptions = true
                } else {
                    self.hasMoreSubscriptions = false
                }
                for item in items {
                    self.subscriptionObjects.append(Subscriptions(ID: item["info"]["id"].int64Value, customerId: item["info"]["customer_id"].int64Value, period: item["info"]["period"].stringValue, initialAmount: item["info"]["initial_amount"].doubleValue, recurringAmount: item["info"]["recurring_amount"].doubleValue, billTimes: item["info"]["bill_times"].int64Value, transactionId: item["info"]["transaction_id"].stringValue, parentPaymentId: item["info"]["parent_payment_id"].int64Value, productId: item["info"]["product_id"].int64Value, created: sharedDateFormatter.dateFromString(item["info"]["created"].stringValue), expiration: sharedDateFormatter.dateFromString(item["info"]["expiration"].stringValue), status: item["info"]["status"].stringValue, profileId: item["info"]["profile_id"].stringValue, gateway: item["info"]["gateway"].stringValue, customer: item["info"]["customer"].dictionaryValue, renewalPayments: item["payments"].array))
                }
                
                self.subscriptionObjects.sortInPlace({ $0.created.compare($1.created) == NSComparisonResult.OrderedDescending })
                self.filteredSubscriptionObjects = self.subscriptionObjects
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
            
            self.updateLastDownloadedPage()
            self.operation = false
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    fileprivate func updateLastDownloadedPage() {
        self.lastDownloadedPage = self.lastDownloadedPage + 1;
        sharedDefaults.set(lastDownloadedPage, forKey: "\(Site.activeSite().uid)-SubscriptionsPage")
        sharedDefaults.synchronize()
    }

    // MARK: Scroll View Delegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let actualPosition: CGFloat = scrollView.contentOffset.y
        let contentHeight: CGFloat = scrollView.contentSize.height - tableView.frame.size.height;
        
        if actualPosition >= contentHeight && hasMoreSubscriptions && !operation {
            self.requestNextPage()
        }
    }
    
    // MARK: Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredSubscriptionObjects.count ?? 0
    }
    
    // MARK: Table View Delegate

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: SubscriptionsTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "SubscriptionsTableViewCell") as! SubscriptionsTableViewCell?
        
        if cell == nil {
            cell = SubscriptionsTableViewCell()
        }
        
        cell!.configure(filteredSubscriptionObjects[indexPath.row])
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                navigationController?.pushViewController(SubscriptionsDetailViewController(subscription: filteredSubscriptionObjects[indexPath.row]), animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension SubscriptionsViewController : InfiniteScrollingTableView {
    
    func setupInfiniteScrollView() {
        let bounds = UIScreen.main.bounds
        let width = bounds.size.width
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 44))
        footerView.backgroundColor = .clear
        
        activityIndicatorView.startAnimating()
        
        footerView.addSubview(activityIndicatorView)
        
        tableView.tableFooterView = footerView
    }
    
}
