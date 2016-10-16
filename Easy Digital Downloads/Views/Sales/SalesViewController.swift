//
//  SalesViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 28/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON
import Haneke

private let sharedDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}()

public struct Sales {
    var ID: Int64!
    var transactionId: String?
    var key: String?
    var subtotal: Double!
    var tax: Double?
    var fees: [SwiftyJSON.JSON]?
    var total: Double!
    var gateway: String!
    var email: String!
    var date: NSDate!
    var discounts: [String: SwiftyJSON.JSON]?
    var products: [SwiftyJSON.JSON]!
    var licenses: [SwiftyJSON.JSON]?
}

class SalesViewController: SiteTableViewController, UIViewControllerPreviewingDelegate {
    
    var managedObjectContext: NSManagedObjectContext!

    typealias JSON = SwiftyJSON.JSON
    
    var site: Site?
    var sales: JSON?
    let sharedCache = Shared.dataCache
    
    var saleObjects = [Sales]()
    var filteredSaleObjects = [Sales]()
    
    var hasMoreSales: Bool = true {
        didSet {
            if (!hasMoreSales) {
                activityIndicatorView.stopAnimating()
            } else {
                activityIndicatorView.startAnimating()
            }
        }
    }
    
    let sharedDefaults: NSUserDefaults = NSUserDefaults(suiteName: "group.easydigitaldownloads.EDDSalesTracker")!
    
    var lastDownloadedPage = NSUserDefaults(suiteName: "group.easydigitaldownloads.EDDSalesTracker")!.integerForKey("\(Site.activeSite().uid)-SalesPage") ?? 1
    
    init(site: Site) {
        super.init(style: .Plain)
        
        self.site = site
        self.managedObjectContext = AppDelegate.sharedInstance.managedObjectContext
        
        title = NSLocalizedString("Sales", comment: "Sales title")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 85.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.registerClass(SalesTableViewCell.self, forCellReuseIdentifier: "SalesTableViewCell")
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(NSLocalizedString("Sales", comment: "Sales title"))
        navigationItem.titleView = titleLabel
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        networkOperations()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.leftBarButtonItem = true
        
        let filterNavigationItemImage = UIImage(named: "NavigationBar-Filter")
        let filterNavigationItemButton = HighlightButton(type: .Custom)
        filterNavigationItemButton.tintColor = .whiteColor()
        filterNavigationItemButton.setImage(filterNavigationItemImage, forState: .Normal)
        filterNavigationItemButton.addTarget(self, action: #selector(SalesViewController.filterButtonPressed), forControlEvents: .TouchUpInside)
        filterNavigationItemButton.sizeToFit()
        
        let filterNavigationBarButton = UIBarButtonItem(customView: filterNavigationItemButton)
        filterNavigationBarButton.accessibilityIdentifier = "Filter"
        
        let searchNavigationItemImage = UIImage(named: "NavigationBar-Search")
        let searchNavigationItemButton = HighlightButton(type: .Custom)
        searchNavigationItemButton.tintColor = .whiteColor()
        searchNavigationItemButton.setImage(searchNavigationItemImage, forState: .Normal)
        searchNavigationItemButton.addTarget(self, action: #selector(SalesViewController.searchButtonPressed), forControlEvents: .TouchUpInside)
        searchNavigationItemButton.sizeToFit()
        
        let searchNavigationBarButton = UIBarButtonItem(customView: searchNavigationItemButton)
        searchNavigationBarButton.accessibilityIdentifier = "Search"
        
        navigationItem.rightBarButtonItems = [searchNavigationBarButton, filterNavigationBarButton]
        
        registerForPreviewingWithDelegate(self, sourceView: view)
        
        sharedCache.fetch(key: Site.activeSite().uid! + "-Sales").onSuccess({ result in
            let json = JSON.convertFromData(result)! as JSON
            self.sales = json
            
            if let items = json["sales"].array {
                for item in items {
                    self.saleObjects.append(Sales(ID: item["ID"].int64Value, transactionId: item["transaction_id"].string, key: item["key"].string, subtotal: item["subtotal"].doubleValue, tax: item["tax"].double, fees: item["fees"].array, total: item["total"].doubleValue, gateway: item["gateway"].stringValue, email: item["email"].stringValue, date: sharedDateFormatter.dateFromString(item["date"].stringValue), discounts: item["discounts"].dictionary, products: item["products"].arrayValue, licenses: item["licenses"].array))
                }
            }
            
            self.saleObjects.sortInPlace({ $0.date.compare($1.date) == NSComparisonResult.OrderedDescending })
            self.filteredSaleObjects = self.saleObjects
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        })
        
        setupInfiniteScrollView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func networkOperations() {
        EDDAPIWrapper.sharedInstance.requestSales([ : ], success: { json in
            self.sharedCache.set(value: json.asData(), key: Site.activeSite().uid! + "-Sales")
            
            self.saleObjects.removeAll(keepCapacity: false)
            
            if let items = json["sales"].array {
                for item in items {
                    self.saleObjects.append(Sales(ID: item["ID"].int64Value, transactionId: item["transaction_id"].string, key: item["key"].string, subtotal: item["subtotal"].doubleValue, tax: item["tax"].double, fees: item["fees"].array, total: item["total"].doubleValue, gateway: item["gateway"].stringValue, email: item["email"].stringValue, date: sharedDateFormatter.dateFromString(item["date"].stringValue), discounts: item["discounts"].dictionary, products: item["products"].arrayValue, licenses: item["licenses"].array))
                }
                
                if items.count <= 20 {
                    self.hasMoreSales = false
                    dispatch_async(dispatch_get_main_queue(), {
                        self.activityIndicatorView.stopAnimating()
                    })
                }
            }
            
            self.saleObjects.sortInPlace({ $0.date.compare($1.date) == NSComparisonResult.OrderedDescending })
            self.filteredSaleObjects = self.saleObjects
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
            
            }) { (error) in
                print(error)
        }
    }
    
    private func requestNextPage() {
        EDDAPIWrapper.sharedInstance.requestSales([ "page": lastDownloadedPage ], success: { (json) in
            if let items = json["sales"].array {
                if items.count == 20 {
                    self.hasMoreSales = true
                } else {
                    self.hasMoreSales = false
                }
                for item in items {
                    
                }
                self.updateLastDownloadedPage()
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    private func updateLastDownloadedPage() {
        self.lastDownloadedPage = self.lastDownloadedPage + 1;
        sharedDefaults.setInteger(lastDownloadedPage, forKey: "\(Site.activeSite().uid)-SalesPage")
        sharedDefaults.synchronize()
    }
    
    // MARK: Scroll View Delegate
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let actualPosition: CGFloat = scrollView.contentOffset.y
        let contentHeight: CGFloat = scrollView.contentSize.height - tableView.frame.size.height;
        
        if actualPosition >= contentHeight && hasMoreSales {
            self.requestNextPage()
        }
    }
    
    // MARK: Table View Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredSaleObjects.count ?? 0
    }
    
    // MARK: Table View Delegate
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: SalesTableViewCell? = tableView.dequeueReusableCellWithIdentifier("SalesTableViewCell") as! SalesTableViewCell?
        
        if cell == nil {
            cell = SalesTableViewCell()
        }
        
        cell!.configure(filteredSaleObjects[indexPath.row])
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        navigationController?.pushViewController(SalesDetailViewController(sale: filteredSaleObjects[indexPath.row]), animated: true)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: 3D Touch
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRowAtPoint(location) {
            previewingContext.sourceRect = tableView.rectForRowAtIndexPath(indexPath)
            return SalesDetailViewController(sale: filteredSaleObjects[indexPath.row])
        }
        return nil
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
    func filterButtonPressed() {
        let salesFilterNavigationController: UINavigationController = UINavigationController(rootViewController: SalesFilterTableViewController())
        salesFilterNavigationController.modalPresentationStyle = .FullScreen
        salesFilterNavigationController.modalPresentationCapturesStatusBarAppearance = true
        presentViewController(salesFilterNavigationController, animated: true, completion: nil)
    }
    
    func searchButtonPressed() {
        navigationController?.pushViewController(SalesSearchViewController(), animated: true)
    }
    
}

extension SalesViewController : InfiniteScrollingTableView {
    
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
