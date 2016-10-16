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

class ProductsViewController: SiteTableViewController, ManagedObjectContextSettable, UIViewControllerPreviewingDelegate {

    var managedObjectContext: NSManagedObjectContext!
    
    var isLoadingProducts = false
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
    
    var lastDownloadedPage =  1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.leftBarButtonItem = true
        
        let searchNavigationItemImage = UIImage(named: "NavigationBar-Search")
        let searchNavigationItemButton = HighlightButton(type: .Custom)
        searchNavigationItemButton.tintColor = .whiteColor()
        searchNavigationItemButton.setImage(searchNavigationItemImage, forState: .Normal)
        searchNavigationItemButton.addTarget(self, action: #selector(ProductsViewController.searchButtonPressed), forControlEvents: .TouchUpInside)
        searchNavigationItemButton.sizeToFit()
        
        let searchNavigationBarButton = UIBarButtonItem(customView: searchNavigationItemButton)
        searchNavigationBarButton.accessibilityIdentifier = "Search"
        
        navigationItem.rightBarButtonItems = [searchNavigationBarButton]
        
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
        
        title = NSLocalizedString("Products", comment: "Products title")
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(NSLocalizedString("Products", comment: "Products title"))
        navigationItem.titleView = titleLabel
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        networkOperations()
    }
    
    func searchButtonPressed() {
        navigationController?.pushViewController(SearchViewController(site: Site.activeSite()), animated: true)
    }
    
    func networkOperations() {
        products = [JSON]()
        
        self.isLoadingProducts = true
        
        EDDAPIWrapper.sharedInstance.requestProducts([:], success: { (json) in
            self.isLoadingProducts = false
            if let items = json["products"].array {
                self.products = items
                self.updateLastDownloadedPage()
            }
        }) { (error) in
            NSLog(error.localizedDescription)
        }
    }
    
    private func updateLastDownloadedPage() {
        self.lastDownloadedPage = self.lastDownloadedPage + 1;
    }
    
    // MARK: Scroll View Delegate
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let actualPosition: CGFloat = scrollView.contentOffset.y
        let contentHeight: CGFloat = scrollView.contentSize.height - tableView.frame.size.height;
        
        if actualPosition >= contentHeight && !isLoadingProducts {
            self.requestNextPage()
        }
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
        self.isLoadingProducts = true
        EDDAPIWrapper.sharedInstance.requestProducts([ "page": lastDownloadedPage ], success: { (json) in
            self.isLoadingProducts = false
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
            print(error.localizedDescription)
        }

    }
    
    private func persistProducts() {
        guard let products_ = products else {
            return
        }
        
        for item in products_.unique {
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
            
            Product.insertIntoContext(managedObjectContext, content: item["info"]["content"].stringValue, createdDate: sharedDateFormatter.dateFromString(item["info"]["create_date"].stringValue)!, files: files, hasVariablePricing: hasVariablePricing, link: item["info"]["link"].stringValue, modifiedDate: sharedDateFormatter.dateFromString(item["info"]["modified_date"].stringValue)!, notes: notes, pid: item["info"]["id"].int64Value, pricing: pricing, stats: stats, status: item["info"]["status"].stringValue, thumbnail: item["info"]["thumbnail"].stringValue, title: item["info"]["title"].stringValue, licensing: item["licensing"].dictionaryObject)
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
    
    // MARK: 3D Touch
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRowAtPoint(location) {
            previewingContext.sourceRect = tableView.rectForRowAtIndexPath(indexPath)
            guard let product = dataSource.objectAtIndexPath(indexPath) else {
                return nil
            }
            return ProductsDetailViewController(product: product)
        }
        return nil
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
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
