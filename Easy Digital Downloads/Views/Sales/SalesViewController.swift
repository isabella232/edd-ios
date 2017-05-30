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

private let sharedDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
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
    var date: Date!
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
    
    var operation = false
    
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
    
    let sharedDefaults: UserDefaults = UserDefaults(suiteName: "group.easydigitaldownloads.EDDSalesTracker")!
    
    var lastDownloadedPage = 2
    
    init(site: Site) {
        super.init(style: .plain)
        
        self.site = site
        self.managedObjectContext = AppDelegate.sharedInstance.managedObjectContext
        
        title = NSLocalizedString("Sales", comment: "Sales title")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 85.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.register(SalesTableViewCell.self, forCellReuseIdentifier: "SalesTableViewCell")
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(NSLocalizedString("Sales", comment: "Sales title"))
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
        
        super.leftBarButtonItem = true
        
        let filterNavigationItemImage = UIImage(named: "NavigationBar-Filter")
        let filterNavigationItemButton = HighlightButton(type: .custom)
        filterNavigationItemButton.tintColor = .white
        filterNavigationItemButton.setImage(filterNavigationItemImage, for: UIControlState())
        filterNavigationItemButton.addTarget(self, action: #selector(SalesViewController.filterButtonPressed), for: .touchUpInside)
        filterNavigationItemButton.sizeToFit()
        
        let filterNavigationBarButton = UIBarButtonItem(customView: filterNavigationItemButton)
        filterNavigationBarButton.accessibilityIdentifier = "Filter"
        
        let searchNavigationItemImage = UIImage(named: "NavigationBar-Search")
        let searchNavigationItemButton = HighlightButton(type: .custom)
        searchNavigationItemButton.tintColor = .white
        searchNavigationItemButton.setImage(searchNavigationItemImage, for: UIControlState())
        searchNavigationItemButton.addTarget(self, action: #selector(SalesViewController.searchButtonPressed), for: .touchUpInside)
        searchNavigationItemButton.sizeToFit()
        
        let searchNavigationBarButton = UIBarButtonItem(customView: searchNavigationItemButton)
        searchNavigationBarButton.accessibilityIdentifier = "Search"
        
        navigationItem.rightBarButtonItems = [searchNavigationBarButton, filterNavigationBarButton]
        
        registerForPreviewing(with: self, sourceView: view)
        
        sharedCache.fetch(key: Site.activeSite().uid! + "-Sales").onSuccess({ result in
            let json = JSON.convertFromData(result)! as JSON
            self.sales = json
            
            if let items = json["sales"].array {
                for item in items {
                    self.saleObjects.append(Sales(ID: item["ID"].int64Value, transactionId: item["transaction_id"].string, key: item["key"].string, subtotal: item["subtotal"].doubleValue, tax: item["tax"].double, fees: item["fees"].array, total: item["total"].doubleValue, gateway: item["gateway"].stringValue, email: item["email"].stringValue, date: sharedDateFormatter.datemfrom: ["date"].stringValue), discounts: item["discounts"].dictionary, products: item["products"].arrayValue, licenses: item["licenses"].array))
                }
            }
            
            self.saleObjects.sortInPlace({ $0.date.compare($1.date) == ComparisonResult.OrderedDescending })
            self.filteredSaleObjects = self.saleObjects
            
            dispatch_get_main_queue().async(execute: {
                self.tableView.reloadData()
            })
        })
        
        setupInfiniteScrollView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    fileprivate func networkOperations() {
        operation = true
        
        EDDAPIWrapper.sharedInstance.requestSales([ : ], success: { json in
            self.sharedCache.set(value: json.asData(), key: Site.activeSite().uid! + "-Sales")
            
            self.saleObjects.removeAll(keepingCapacity: false)
            
            if let items = json["sales"].array {
                for item in items {
                    self.saleObjects.append(Sales(ID: item["ID"].int64Value, transactionId: item["transaction_id"].string, key: item["key"].string, subtotal: item["subtotal"].doubleValue, tax: item["tax"].double, fees: item["fees"].array, total: item["total"].doubleValue, gateway: item["gateway"].stringValue, email: item["email"].stringValue, date: sharedDateFormatter.datemfrom: ["date"].stringValue), discounts: item["discounts"].dictionary, products: item["products"].arrayValue, licenses: item["licenses"].array))
                }
                
                if items.count < 10 {
                    self.hasMoreSales = false
                    dispatch_get_maDispatchQueue.main {
                        self.activityIndicatorView.stopAnimating()
                    })
                }
            }
            
            self.saleObjects.sortInPlace({ $0.date.compare($1.date) == ComparisonResult.OrderedDescending })
            self.filteredSaleObjects = self.saleObjects

            dispatch_get_maDispatchQueue.main {
                self.tableView.reloadData()
            })
            
            self.operation = false
        }) { (error) in
            print(error)
        }
    }
    
    fileprivate func requestNextPage() {
        if (operation) {
            return
        }
        
        operation = true
        
        EDDAPIWrapper.sharedInstance.requestSales([ "page": lastDownloadedPage as AnyObject ], success: { (json) in
            if let items = json["sales"].array {
                if items.count == 10 {
                    self.hasMoreSales = true
                } else {
                    self.hasMoreSales = false
                }
                for item in items {
                    self.saleObjects.append(Sales(ID: item["ID"].int64Value, transactionId: item["transaction_id"].string, key: item["key"].string, subtotal: item["subtotal"].doubleValue, tax: item["tax"].double, fees: item["fees"].array, total: item["total"].doubleValue, gateway: item["gateway"].stringValue, email: item["email"].stringValue, date: sharedDateFormatter.dateFromString(item["date"].stringValue), discounts: item["discounts"].dictionary, products: item["products"].arrayValue, licenses: item["licenses"].array))
                }
                self.updateLastDownloadedPage()
            } else {
                self.hasMoreSales = false
                dispatch_async(DispatchQueue.main, {
                    self.activityIndicatorView.stopAnimating()
                })
            }
            
            self.saleObjects.sortInPlace({ $0.date.compare($1.date) == ComparisonResult.orderedDescending })
            self.filteredSaleObjects = self.saleObjects
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
            
            self.operation = false
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    fileprivate func updateLastDownloadedPage() {
        self.lastDownloadedPage = self.lastDownloadedPage + 1;
        sharedDefaults.set(lastDownloadedPage, forKey: "\(String(describing: Site.activeSite().uid))-SalesPage")
        sharedDefaults.synchronize()
    }
    
    // MARK: Scroll View Delegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let actualPosition: CGFloat = scrollView.contentOffset.y
        let contentHeight: CGFloat = scrollView.contentSize.height - tableView.frame.size.height;
        
        if actualPosition >= contentHeight && hasMoreSales && !operation {
            self.requestNextPage()
        }
    }
    
    // MARK: Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredSaleObjects.count 
    }
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: SalesTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "SalesTableViewCell") as! SalesTableViewCell?
        
        if cell == nil {
            cell = SalesTableViewCell()
        }
        
        cell!.configure(filteredSaleObjects[indexPath.row])
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        navigationController?.pushViewController(SalesDetailViewController(sale: filteredSaleObjects[indexPath.row]), animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: 3D Touch
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRow(at: location) {
            previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
            return SalesDetailViewController(sale: filteredSaleObjects[indexPath.row])
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
    func filterButtonPressed() {
        let salesFilterNavigationController: UINavigationController = UINavigationController(rootViewController: SalesFilterTableViewController())
        salesFilterNavigationController.modalPresentationStyle = .fullScreen
        salesFilterNavigationController.modalPresentationCapturesStatusBarAppearance = true
        present(salesFilterNavigationController, animated: true, completion: nil)
    }
    
    func searchButtonPressed() {
        navigationController?.pushViewController(SalesSearchViewController(), animated: true)
    }
    
}

extension SalesViewController : InfiniteScrollingTableView {
    
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
