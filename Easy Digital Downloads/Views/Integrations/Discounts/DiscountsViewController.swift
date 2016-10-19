//
//  DiscountsViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 24/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import SwiftyJSON
import Haneke

private let sharedDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    formatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
    return formatter
}()

public struct Discounts {
    var ID: Int64!
    var name: String!
    var code: String!
    var amount: Double!
    var minPrice: Double!
    var type: String!
    var startDate: NSDate?
    var expiryDate: NSDate?
    var status: String!
    var globalDiscount: Bool!
    var singleUse: Bool!
    var productRequirements: [String: SwiftyJSON.JSON]?
    var requirementCondition: String!
}

class DiscountsViewController: SiteTableViewController {

    var discountsObjects = [Discounts]()
    
    typealias JSON = SwiftyJSON.JSON
    
    var site: Site?
    var discounts: JSON?
    let sharedCache = Shared.dataCache
    
    var operation = false
    
    var hasMoreDiscounts: Bool = true {
        didSet {
            if (!hasMoreDiscounts) {
                activityIndicatorView.stopAnimating()
            } else {
                activityIndicatorView.startAnimating()
            }
        }
    }
    
    let sharedDefaults: NSUserDefaults = NSUserDefaults(suiteName: "group.easydigitaldownloads.EDDSalesTracker")!
    
    var lastDownloadedPage = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sharedCache.fetch(key: "Discounts").onSuccess({ result in
            let json = JSON.convertFromData(result)! as JSON
            self.discounts = json
            
            if let items = json["discounts"].array {
                if items.count == 20 {
                    self.hasMoreDiscounts = true
                } else {
                    self.hasMoreDiscounts = false
                    dispatch_async(dispatch_get_main_queue(), { 
                        self.activityIndicatorView.stopAnimating()
                    })
                }
                
                for item in items {
                    var startDate: NSDate?
                    var expDate: NSDate?
                    
                    if item["start_date"].stringValue.characters.count == 0 {
                        startDate = nil
                    } else {
                        startDate = sharedDateFormatter.dateFromString(item["start_date"].stringValue)
                    }
                    
                    if item["exp_date"].stringValue.characters.count == 0 {
                        expDate = nil
                    } else {
                        expDate = sharedDateFormatter.dateFromString(item["exp_date"].stringValue)
                    }
                    
                    self.discountsObjects.append(Discounts(ID: item["ID"].int64Value, name: item["name"].stringValue, code: item["code"].stringValue, amount: item["amount"].doubleValue, minPrice: item["min_price"].doubleValue, type: item["type"].stringValue, startDate: startDate, expiryDate: expDate, status: item["status"].stringValue, globalDiscount: item["global_discounts"].boolValue, singleUse: item["single_use"].boolValue, productRequirements: item["product_requirements"].dictionary, requirementCondition: item["requirement_condition"].stringValue))
                }
            }
            
            self.discountsObjects.sortInPlace({ $0.ID > $1.ID })
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        })
        
        setupInfiniteScrollView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    init(site: Site) {
        super.init(style: .Plain)
        
        self.site = site
        
        title = NSLocalizedString("Discounts", comment: "Discounts title")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 85.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(NSLocalizedString("Discounts", comment: "Discounts title"))
        navigationItem.titleView = titleLabel
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        networkOperations()
    }
    
    private func networkOperations() {
        operation = true
        
        EDDAPIWrapper.sharedInstance.requestDiscounts([ : ], success: { (result) in
            self.sharedCache.set(value: result.asData(), key: "Discounts")
            
            self.discountsObjects.removeAll(keepCapacity: false)
            
            if let items = result["discounts"].array {
                if items.count == 10 {
                    self.hasMoreDiscounts = true
                } else {
                    self.hasMoreDiscounts = false
                    dispatch_async(dispatch_get_main_queue(), { 
                        self.activityIndicatorView.stopAnimating()
                    })
                }
                
                
                for item in items {
                    var startDate: NSDate?
                    var expDate: NSDate?
                    
                    if item["start_date"].stringValue.characters.count == 0 {
                        startDate = nil
                    } else {
                        startDate = sharedDateFormatter.dateFromString(item["start_date"].stringValue)
                    }
                    
                    if item["exp_date"].stringValue.characters.count == 0 {
                        expDate = nil
                    } else {
                        expDate = sharedDateFormatter.dateFromString(item["exp_date"].stringValue)
                    }
                    
                    self.discountsObjects.append(Discounts(ID: item["ID"].int64Value, name: item["name"].stringValue, code: item["code"].stringValue, amount: item["amount"].doubleValue, minPrice: item["min_price"].doubleValue, type: item["type"].stringValue, startDate: startDate, expiryDate: expDate, status: item["status"].stringValue, globalDiscount: item["global_discounts"].boolValue, singleUse: item["single_use"].boolValue, productRequirements: item["product_requirements"].dictionary, requirementCondition: item["requirement_condition"].stringValue))
                }
            }
            
            self.discountsObjects.sortInPlace({ $0.ID > $1.ID })
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
            
            self.operation = false
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    private func requestNextPage() {
        operation = true

        EDDAPIWrapper.sharedInstance.requestDiscounts(["page" : self.lastDownloadedPage], success: { (result) in
            if let items = result["discounts"].array {
                if items.count == 10 {
                    self.hasMoreDiscounts = true
                } else {
                    self.hasMoreDiscounts = false
                    dispatch_async(dispatch_get_main_queue(), {
                        self.activityIndicatorView.stopAnimating()
                    })
                }
                
                for item in items {
                    var startDate: NSDate?
                    var expDate: NSDate?
                    
                    if item["start_date"].stringValue.characters.count == 0 {
                        startDate = nil
                    } else {
                        startDate = sharedDateFormatter.dateFromString(item["start_date"].stringValue)
                    }
                    
                    if item["exp_date"].stringValue.characters.count == 0 {
                        expDate = nil
                    } else {
                        expDate = sharedDateFormatter.dateFromString(item["exp_date"].stringValue)
                    }
                    
                    self.discountsObjects.append(Discounts(ID: item["ID"].int64Value, name: item["name"].stringValue, code: item["code"].stringValue, amount: item["amount"].doubleValue, minPrice: item["min_price"].doubleValue, type: item["type"].stringValue, startDate: startDate, expiryDate: expDate, status: item["status"].stringValue, globalDiscount: item["global_discounts"].boolValue, singleUse: item["single_use"].boolValue, productRequirements: item["product_requirements"].dictionary, requirementCondition: item["requirement_condition"].stringValue))
                }
                
                self.updateLastDownloadedPage()
            }
            
            self.discountsObjects.sortInPlace({ $0.ID > $1.ID })
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
            
            self.operation = false
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    private func updateLastDownloadedPage() {
        self.lastDownloadedPage = self.lastDownloadedPage + 1;
        sharedDefaults.setInteger(lastDownloadedPage, forKey: "\(Site.activeSite().uid)-DiscountsPage")
        sharedDefaults.synchronize()
    }
    
    // MARK: Scroll View Delegate
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let actualPosition: CGFloat = scrollView.contentOffset.y
        let contentHeight: CGFloat = scrollView.contentSize.height - tableView.frame.size.height;
        
        if actualPosition >= contentHeight && hasMoreDiscounts && !operation {
            self.requestNextPage()
        }
    }
    
    // MARK: Table View Data Source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.discountsObjects.count ?? 0
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        navigationController?.pushViewController(DiscountsDetailViewController(discount: discountsObjects[indexPath.row]), animated: true)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: Table View Delegate
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: DiscountsTableViewCell? = tableView.dequeueReusableCellWithIdentifier("DiscountsCell") as! DiscountsTableViewCell?
        
        if cell == nil {
            cell = DiscountsTableViewCell()
        }
        
        cell?.configure(discountsObjects[indexPath.row])
        
        return cell!
    }

}

extension DiscountsViewController : InfiniteScrollingTableView {
    
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
