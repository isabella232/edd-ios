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

private let sharedDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}()

class SubscriptionsViewController: SiteTableViewController, ManagedObjectContextSettable {

    var managedObjectContext: NSManagedObjectContext!
    
    var site: Site?
    var subscriptions: [JSON]?
    
    var hasMoreSubscriptions: Bool = true {
        didSet {
            if (!hasMoreSubscriptions) {
                activityIndicatorView.stopAnimating()
            } else {
                activityIndicatorView.startAnimating()
            }
        }
    }
    
    var lastDownloadedPage = NSUserDefaults.standardUserDefaults().integerForKey("\(Site.activeSite().uid)-SubscriptionsPage") ?? 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInfiniteScrollView()
        setupTableView()
    }
    
    init(site: Site) {
        super.init(style: .Plain)
        
        self.site = site
        self.managedObjectContext = AppDelegate.sharedInstance.managedObjectContext
        
        title = NSLocalizedString("Subscriptions", comment: "Subscriptions title")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        networkOperations()
    }
    
    private func networkOperations() {
        subscriptions = [JSON]()
        
        EDDAPIWrapper.sharedInstance.requestSubscriptions([ : ], success: { (json) in
            if let items = json["subscriptions"].array {
                self.subscriptions = items
                self.updateLastDownloadedPage()
                self.requestNextPage()
            }
            
        }) { (error) in
            fatalError()
        }
    }
    
    private func requestNextPage() {
        EDDAPIWrapper.sharedInstance.requestSubscriptions([ "page": lastDownloadedPage ], success: { (json) in
            if let items = json["subscriptions"].array {
                if items.count == 20 {
                    self.hasMoreSubscriptions = true
                } else {
                    self.hasMoreSubscriptions = false
                }
                for item in items {
                    self.subscriptions?.append(item)
                }
                self.updateLastDownloadedPage()
            }
            self.persistSubscriptions()
        }) { (error) in
            fatalError()
        }
    }
    
    private func updateLastDownloadedPage() {
        self.lastDownloadedPage = self.lastDownloadedPage + 1;
        NSUserDefaults.standardUserDefaults().setInteger(lastDownloadedPage, forKey: "\(Site.activeSite().uid)-SalesPage")
    }

    private func persistSubscriptions() {
        guard let subscriptions_ = subscriptions else {
            return
        }
        
        for item in subscriptions_ {
            print(item)
            Subscription.insertIntoContext(managedObjectContext, billTimes: item["info"]["bill_times"].int64Value, created: sharedDateFormatter.dateFromString(item["info"]["created"].stringValue)!, customer: item["info"]["customer"].dictionaryObject!, expiration: sharedDateFormatter.dateFromString(item["info"]["expiration"].stringValue)!, gateway: item["info"]["gateway"].stringValue, initialAmount: item["info"]["initial_amount"].doubleValue, notes: item["info"]["customer"]["notes"].arrayObject, parentPaymentID: item["info"]["parent_payment_id"].int64Value, period: item["info"]["period"].stringValue, productID: item["info"]["product_id"].int64Value, profileID: item["info"]["profile_id"].stringValue, recurringAmount: item["info"]["recurring_amount"].doubleValue, sid: item["info"]["id"].int64Value, status: item["info"]["status"].stringValue)
        }
        
        do {
            try managedObjectContext.save()
            managedObjectContext.processPendingChanges()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }

    // MARK: Scroll View Delegate
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let actualPosition: CGFloat = scrollView.contentOffset.y
        let contentHeight: CGFloat = scrollView.contentSize.height - tableView.frame.size.height;
        
        if actualPosition >= contentHeight {
            self.requestNextPage()
        }
    }
    
    // MARK: Table View Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let subscription = dataSource.selectedObject else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            return
        }
        
        
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: Private
    
    private typealias Data = FetchedResultsDataProvider<SubscriptionsViewController>
    private var dataSource: TableViewDataSource<SubscriptionsViewController, Data, SubscriptionsTableViewCell>!
    
    private func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.registerClass(SubscriptionsTableViewCell.self, forCellReuseIdentifier: "SubscriptionCell")
        setupDataSource()
    }
    
    private func setupDataSource() {
        let request = Subscription.defaultFetchRequest()
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        let dataProvider = FetchedResultsDataProvider(fetchedResultsController: frc, delegate: self)
        dataSource = TableViewDataSource(tableView: tableView, dataProvider: dataProvider, delegate: self)
    }

}

extension SubscriptionsViewController: DataProviderDelegate {
    
    func dataProviderDidUpdate(updates: [DataProviderUpdate<Subscription>]?) {
        dataSource.processUpdates(updates)
    }
    
}

extension SubscriptionsViewController: DataSourceDelegate {
    
    func cellIdentifierForObject(object: Subscription) -> String {
        return "SubscriptionCell"
    }
    
}

extension SubscriptionsViewController : InfiniteScrollingTableView {
    
    func setupInfiniteScrollView() {
        let bounds = UIScreen.mainScreen().bounds
        let width = bounds.size.width
        
        let footerView = UIView(frame: CGRectMake(0, 0, width, 44))
        footerView.backgroundColor = .clearColor()
        
        activityIndicatorView.startAnimating()
        
        footerView.addSubview(activityIndicatorView)
        
        tableView.tableFooterView = footerView
    }
    
}
