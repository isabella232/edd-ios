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
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
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
}

class DiscountsViewController: SiteTableViewController {

    var discountsObjects = [Discounts]()
    
    typealias JSON = SwiftyJSON.JSON
    
    var site: Site?
    var commissions: JSON?
    let sharedCache = Shared.dataCache
    
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
    
    var lastDownloadedPage = NSUserDefaults(suiteName: "group.easydigitaldownloads.EDDSalesTracker")!.integerForKey("\(Site.activeSite().uid)-DiscountsPage") ?? 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sharedCache.fetch(key: "Discounts").onSuccess({ result in
            let json = JSON.convertFromData(result)! as JSON
            self.commissions = json
            
            if let items = json["discounts"].array {
                for item in items {
                    self.discountsObjects.append(Discounts(ID: item["ID"].int64Value, name: item["name"].stringValue, code: item["code"].stringValue, amount: item["amount"].doubleValue, minPrice: item["min_price"].doubleValue, type: item["type"].stringValue, startDate: sharedDateFormatter.dateFromString(item["start_date"].stringValue), expiryDate: sharedDateFormatter.dateFromString(item["exp_date"].stringValue), status: item["status"].stringValue, globalDiscount: item["global_discounts"].boolValue, singleUse: item["single_use"].boolValue))
                }
            }
            
            self.discountsObjects.sortInPlace({ $0.ID < $1.ID })
            
            self.tableView.reloadData()
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        networkOperations()
    }
    
    private func networkOperations() {
        EDDAPIWrapper.sharedInstance.requestDiscounts([ : ], success: { (json) in
            self.sharedCache.set(value: json.asData(), key: "Discounts")
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    private func requestNextPage() {
        
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
        
        if actualPosition >= contentHeight {
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
