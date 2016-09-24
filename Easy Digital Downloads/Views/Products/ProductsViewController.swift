//
//  ProductsViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 01/09/2016.
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

class ProductsViewController: SiteTableViewController, ManagedObjectContextSettable {

    var managedObjectContext: NSManagedObjectContext!
    
    var site: Site?
    var products: [JSON]?
    
    var hasMoreProducts: Bool = true {
        didSet {
            if (!hasMoreProducts) {
                activityIndicatorView.stopAnimating()
            } else {
                activityIndicatorView.startAnimating()
            }
        }
    }
    
    let sharedDefaults: NSUserDefaults = NSUserDefaults(suiteName: "group.easydigitaldownloads.EDDSalesTracker")!
    
    var lastDownloadedPage = NSUserDefaults(suiteName: "group.easydigitaldownloads.EDDSalesTracker")!.integerForKey("\(Site.activeSite().uid)-ProductsPage") ?? 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.leftBarButtonItem = true
        
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
        
        title = NSLocalizedString("Products", comment: "Products title")
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        networkOperations()
    }
    
    func networkOperations() {
        products = [JSON]()
        
        EDDAPIWrapper.sharedInstance.requestProducts([:], success: { (json) in
            if let items = json["products"].array {
                self.products = items
                self.updateLastDownloadedPage()
                self.requestNextPage()
            }
        }) { (error) in
            NSLog(error.localizedDescription)
        }
    }
    
    private func updateLastDownloadedPage() {
        self.lastDownloadedPage = self.lastDownloadedPage + 1;
        sharedDefaults.setInteger(lastDownloadedPage, forKey: "\(Site.activeSite().uid)-ProductsPage")
        sharedDefaults.synchronize()
    }
    
    // MARK: Table View Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let product = dataSource.selectedObject else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            return
        }
        
        navigationController?.pushViewController(ProductsDetailViewController(product: product), animated: true)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: Private
    
    private func requestNextPage() {
        EDDAPIWrapper.sharedInstance.requestProducts([ "page": lastDownloadedPage ], success: { (json) in
            if let items = json["products"].array {
                if items.count == 20 {
                    self.hasMoreProducts = true
                } else {
                    self.hasMoreProducts = false
                }
                for item in items {
                    self.products?.append(item)
                }
                self.updateLastDownloadedPage()
            }
            self.persistProducts()
        }) { (error) in
            fatalError()
        }

    }
    
    private func persistProducts() {
        guard let products_ = products else {
            return
        }
        
        for item in products_ {
            if Product.productForId(item["info"]["id"].int64Value) !== nil {
                continue
            }
            
            var stats: NSData?
            if Site.hasPermissionToViewReports() {
                stats = NSKeyedArchiver.archivedDataWithRootObject(item["stats"].dictionaryObject!)
            } else {
                stats = nil
            }
            
            var files: NSData?
            var notes: String?
            if Site.hasPermissionToViewSensitiveData() {
                if item["files"].dictionary != nil {
                    files = NSKeyedArchiver.archivedDataWithRootObject(item["files"].dictionaryObject!)
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
            
            Product.insertIntoContext(managedObjectContext, content: item["info"]["content"].stringValue, createdDate: sharedDateFormatter.dateFromString(item["info"]["create_date"].stringValue)!, files: files, hasVariablePricing: hasVariablePricing, link: item["info"]["link"].stringValue, modifiedDate: sharedDateFormatter.dateFromString(item["info"]["modified_date"].stringValue)!, notes: notes, pid: item["info"]["id"].int64Value, pricing: pricing, stats: stats, status: item["info"]["status"].stringValue, thumbnail: item["info"]["thumbnail"].stringValue, title: item["info"]["title"].stringValue)
        }
        
        do {
            try managedObjectContext.save()
            managedObjectContext.processPendingChanges()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    private typealias Data = FetchedResultsDataProvider<ProductsViewController>
    private var dataSource: TableViewDataSource<ProductsViewController, Data, ProductsTableViewCell>!
    
    private func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.registerClass(ProductsTableViewCell.self, forCellReuseIdentifier: "ProductCell")
        tableView.registerClass(ProductsTableViewCell.self, forCellReuseIdentifier: "ProductThumbnailCell")
        setupDataSource()
    }
    
    private func setupDataSource() {
        let request = Product.defaultFetchRequest()
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        let dataProvider = FetchedResultsDataProvider(fetchedResultsController: frc, delegate: self)
        dataSource = TableViewDataSource(tableView: tableView, dataProvider: dataProvider, delegate: self)
    }

}

extension ProductsViewController: DataProviderDelegate {
    
    func dataProviderDidUpdate(updates: [DataProviderUpdate<Product>]?) {
        dataSource.processUpdates(updates)
    }
    
}

extension ProductsViewController: DataSourceDelegate {
    
    func cellIdentifierForObject(object: Product) -> String {
        if object.thumbnail?.characters.count > 5 && object.thumbnail != "false" {
            return "ProductThumbnailCell"
        } else {
            return "ProductCell"
        }
    }
    
}


extension ProductsViewController : InfiniteScrollingTableView {
    
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
