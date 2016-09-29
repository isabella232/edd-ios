//
//  CustomersViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 28/05/2016.
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

class CustomersViewController: SiteTableViewController, ManagedObjectContextSettable, UIViewControllerPreviewingDelegate {

    var managedObjectContext: NSManagedObjectContext!
    
    var site: Site?
    var customers: [JSON]?
    
    var hasMoreCustomers: Bool = true {
        didSet {
            if (!hasMoreCustomers) {
                activityIndicatorView.stopAnimating()
            } else {
                activityIndicatorView.startAnimating()
            }
        }
    }

    let sharedDefaults: NSUserDefaults = NSUserDefaults(suiteName: "group.easydigitaldownloads.EDDSalesTracker")!
    
    var lastDownloadedPage = NSUserDefaults(suiteName: "group.easydigitaldownloads.EDDSalesTracker")!.integerForKey("\(Site.activeSite().uid)-CustomersPage") ?? 1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.leftBarButtonItem = true
        
        registerForPreviewingWithDelegate(self, sourceView: view)
        
        setupInfiniteScrollView()
        setupTableView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    init(site: Site) {
        super.init(style: .Plain)
        
        self.site = site
        self.managedObjectContext = AppDelegate.sharedInstance.managedObjectContext
        
        title = NSLocalizedString("Customers", comment: "Customers title")
    }


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        customers = [JSON]()
        
        EDDAPIWrapper.sharedInstance.requestCustomers([:], success: { (json) in
            if let items = json["customers"].array {
                self.customers = items
                self.updateLastDownloadedPage()
                self.requestNextPage()
            }
            }) { (error) in
                NSLog(error.localizedDescription)
        }
    }
    
    // MARK: Table View Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let customer = dataSource.selectedObject else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            return
        }
        
        navigationController?.pushViewController(CustomersDetailViewController(customer: customer), animated: true)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    
    // MARK: Private
    
    private func requestNextPage() {
        EDDAPIWrapper.sharedInstance.requestCustomers([ "page": lastDownloadedPage ], success: { (json) in
            if let items = json["customers"].array {
                if items.count == 20 {
                    self.hasMoreCustomers = true
                } else {
                    self.hasMoreCustomers = false
                }
                for item in items {
                    self.customers?.append(item)
                }
                self.updateLastDownloadedPage()
            } else {
                self.hasMoreCustomers = false
            }
            self.persistCustomers()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    private func updateLastDownloadedPage() {
        self.lastDownloadedPage = self.lastDownloadedPage + 1;
        sharedDefaults.setInteger(lastDownloadedPage, forKey: "\(Site.activeSite().uid)-CustomersPage")
        sharedDefaults.synchronize()
    }
    
    private func persistCustomers() {
        guard let customers_ = customers else {
            return
        }
        
        for item in customers_.unique {
            if Customer.customerForId(item["info"]["user_id"].int64Value) !== nil {
                continue
            }
            
            Customer.insertIntoContext(managedObjectContext, displayName: item["info"]["display_name"].stringValue, email: item["info"]["email"].stringValue, firstName: item["info"]["first_name"].stringValue, lastName: item["info"]["last_name"].stringValue, totalDownloads: item["stats"]["total_downloads"].int64Value, totalPurchases: item["stats"]["total_purchases"].int64Value, totalSpent: item["stats"]["total_spent"].doubleValue, uid: item["info"]["user_id"].int64Value, username: item["username"].stringValue, dateCreated: sharedDateFormatter.dateFromString(item["info"]["date_created"].stringValue)!)
        }
        
        do {
            try managedObjectContext.save()
            managedObjectContext.processPendingChanges()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    private typealias Data = FetchedResultsDataProvider<CustomersViewController>
    private var dataSource: TableViewDataSource<CustomersViewController, Data, CustomersTableViewCell>!
    
    private func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.registerClass(CustomersTableViewCell.self, forCellReuseIdentifier: "CustomerCell")
        setupDataSource()
    }
    
    private func setupDataSource() {
        let request = Customer.defaultFetchRequest()
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        let dataProvider = FetchedResultsDataProvider(fetchedResultsController: frc, delegate: self)
        dataSource = TableViewDataSource(tableView: tableView, dataProvider: dataProvider, delegate: self)
    }
    
    // MARK: 3D Touch
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRowAtPoint(location) {
            previewingContext.sourceRect = tableView.rectForRowAtIndexPath(indexPath)
            guard let customer = dataSource.objectAtIndexPath(indexPath) else {
                return nil
            }
            return CustomersDetailViewController(customer: customer)
        }
        return nil
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
}

extension CustomersViewController: DataProviderDelegate {
    
    func dataProviderDidUpdate(updates: [DataProviderUpdate<Customer>]?) {
        dataSource.processUpdates(updates)
    }
    
}

extension CustomersViewController: DataSourceDelegate {
    
    func cellIdentifierForObject(object: Customer) -> String {
        return "CustomerCell"
    }
    
}

extension CustomersViewController : InfiniteScrollingTableView {
    
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
