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

private let sharedDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
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

    let sharedDefaults: UserDefaults = UserDefaults(suiteName: "group.easydigitaldownloads.EDDSalesTracker")!
    
    var lastDownloadedPage =  1
    
    init(site: Site) {
        super.init(style: .plain)
        
        self.site = site
        self.managedObjectContext = AppDelegate.sharedInstance.managedObjectContext
        
        title = NSLocalizedString("Customers", comment: "Customers title")
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(NSLocalizedString("Customers", comment: "Customers title"))
        navigationItem.titleView = titleLabel
    }


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.leftBarButtonItem = true
        
        registerForPreviewing(with: self, sourceView: view)
        
        let searchNavigationItemImage = UIImage(named: "NavigationBar-Search")
        let searchNavigationItemButton = HighlightButton(type: .custom)
        searchNavigationItemButton.tintColor = .white
        searchNavigationItemButton.setImage(searchNavigationItemImage, for: UIControlState())
        searchNavigationItemButton.addTarget(self, action: #selector(CustomersViewController.searchButtonPressed), for: .touchUpInside)
        searchNavigationItemButton.sizeToFit()
        
        let searchNavigationBarButton = UIBarButtonItem(customView: searchNavigationItemButton)
        searchNavigationBarButton.accessibilityIdentifier = "Search"
        
        navigationItem.rightBarButtonItems = [searchNavigationBarButton]
        
        setupInfiniteScrollView()
        setupTableView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func searchButtonPressed() {
        navigationController?.pushViewController(CustomersSearchViewController(), animated: true)
    }
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let customer = dataSource.selectedObject else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        navigationController?.pushViewController(CustomersDetailViewController(customer: customer), animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    // MARK: Private
    
    fileprivate func requestNextPage() {
        EDDAPIWrapper.sharedInstance.requestCustomers([ "page": lastDownloadedPage as AnyObject ], success: { (json) in
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
    
    fileprivate func updateLastDownloadedPage() {
        self.lastDownloadedPage = self.lastDownloadedPage + 1;
        sharedDefaults.set(lastDownloadedPage, forKey: "\(String(describing: Site.activeSite().uid))-CustomersPage")
        sharedDefaults.synchronize()
    }
    
    fileprivate func persistCustomers() {
        guard let customers_ = customers else {
            return
        }
        
        for item in customers_.unique {
            if Customer.customerForId(item["info"]["customer_id"].int64Value) !== nil {
                continue
            }
            
            Customer.insertIntoContext(managedObjectContext, displayName: item["info"]["display_name"].stringValue, email: item["info"]["email"].stringValue, firstName: item["info"]["first_name"].stringValue, lastName: item["info"]["last_name"].stringValue, totalDownloads: item["stats"]["total_downloads"].int64Value, totalPurchases: item["stats"]["total_purchases"].int64Value, totalSpent: item["stats"]["total_spent"].doubleValue, uid: item["info"]["customer_id"].int64Value, username: item["username"].stringValue, dateCreated: sharedDateFormatter.date(from: item["info"]["date_created"].stringValue)!)
        }
        
        do {
            try managedObjectContext.save()
            managedObjectContext.processPendingChanges()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    fileprivate typealias Data = FetchedResultsDataProvider<CustomersViewController>
    fileprivate var dataSource: TableViewDataSource<CustomersViewController, Data, CustomersTableViewCell>!
    
    fileprivate func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.register(CustomersTableViewCell.self, forCellReuseIdentifier: "CustomerCell")
        setupDataSource()
    }
    
    fileprivate func setupDataSource() {
        let request = Customer.defaultFetchRequest()
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        let dataProvider = FetchedResultsDataProvider(fetchedResultsController: frc, delegate: self)
        dataSource = TableViewDataSource(tableView: tableView, dataProvider: dataProvider, delegate: self)
    }
    
    // MARK: 3D Touch
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRow(at: location) {
            previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
            guard let customer = dataSource.objectAtIndexPath(indexPath) else {
                return nil
            }
            return CustomersDetailViewController(customer: customer)
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
}

extension CustomersViewController: DataProviderDelegate {
    
    func dataProviderDidUpdate(_ updates: [DataProviderUpdate<Customer>]?) {
        dataSource.processUpdates(updates)
    }
    
}

extension CustomersViewController: DataSourceDelegate {
    
    func cellIdentifierForObject(_ object: Customer) -> String {
        return "CustomerCell"
    }
    
}

extension CustomersViewController : InfiniteScrollingTableView {
    
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
