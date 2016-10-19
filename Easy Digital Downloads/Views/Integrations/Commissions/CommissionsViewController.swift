//
//  CommissionsViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 29/09/2016.
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

public struct Commissions {
    var amount: Double!
    var rate: Double!
    var currency: String!
    var renewal: Int64?
    var item: String!
    var date: NSDate!
    var status: String!
}

class CommissionsViewController: SiteTableViewController {
    
    var commissionsObjects = [Commissions]()
    var filteredCommissionsObjects = [Commissions]()
    
    typealias JSON = SwiftyJSON.JSON
    
    var site: Site?
    var commissions: JSON?
    let sharedCache = Shared.dataCache
    var segmentedControl: UISegmentedControl!
    
    var hasMoreCommissions: Bool = true {
        didSet {
            if (!hasMoreCommissions) {
                activityIndicatorView.stopAnimating()
            } else {
                activityIndicatorView.startAnimating()
            }
        }
    }
    
    let sharedDefaults: NSUserDefaults = NSUserDefaults(suiteName: "group.easydigitaldownloads.EDDSalesTracker")!
    
    var lastDownloadedPage = NSUserDefaults(suiteName: "group.easydigitaldownloads.EDDSalesTracker")!.integerForKey("\(Site.activeSite().uid)-CommissionsPage") ?? 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedControl = UISegmentedControl(items: [NSLocalizedString("All", comment: ""), NSLocalizedString("Unpaid", comment: ""), NSLocalizedString("Paid", comment: ""), NSLocalizedString("Revoked", comment: "")])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.tintColor = .whiteColor()
        segmentedControl.autoresizingMask = [.FlexibleWidth]
        segmentedControl.frame = CGRectMake(0, 0, 400, 30)
        segmentedControl.contentMode = .ScaleToFill
        segmentedControl.addTarget(self, action: #selector(CommissionsViewController.segmentAction), forControlEvents: .ValueChanged)
        segmentedControl.sizeToFit()
        
        sharedCache.fetch(key: Site.activeSite().uid! + "-Commissions").onSuccess({ result in
            let json = JSON.convertFromData(result)! as JSON
            self.commissions = json
            
            if let revoked = json["revoked"].array {
                for item in revoked {
                    self.commissionsObjects.append(Commissions(amount: item["amount"].doubleValue, rate: item["rate"].doubleValue, currency: item["currency"].stringValue, renewal: item["renewal"].int64, item: item["item"].stringValue, date: sharedDateFormatter.dateFromString(item["date"].stringValue), status: "revoked"))
                }
            }
            
            if let paid = json["paid"].array {
                for item in paid {
                    self.commissionsObjects.append(Commissions(amount: item["amount"].doubleValue, rate: item["rate"].doubleValue, currency: item["currency"].stringValue, renewal: item["renewal"].int64, item: item["item"].stringValue, date: sharedDateFormatter.dateFromString(item["date"].stringValue), status: "paid"))
                }
            }
            
            if let unpaid = json["unpaid"].array {
                for item in unpaid {
                    self.commissionsObjects.append(Commissions(amount: item["amount"].doubleValue, rate: item["rate"].doubleValue, currency: item["currency"].stringValue, renewal: item["renewal"].int64, item: item["item"].stringValue, date: sharedDateFormatter.dateFromString(item["date"].stringValue), status: "unpaid"))
                }
            }
            
            self.commissionsObjects.sortInPlace({ $0.date.compare($1.date) == NSComparisonResult.OrderedDescending })
            self.filteredCommissionsObjects = self.commissionsObjects
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        })
        
        navigationItem.titleView = segmentedControl

        setupInfiniteScrollView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    init(site: Site) {
        super.init(style: .Plain)
        
        self.site = site
        
        title = NSLocalizedString("Commissions", comment: "Commissions title")
        
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
        EDDAPIWrapper.sharedInstance.requestCommissions([ : ], success: { (json) in
            self.sharedCache.set(value: json.asData(), key: Site.activeSite().uid! + "-Commissions")
            
            self.commissionsObjects.removeAll(keepCapacity: false)
            
            if let revoked = json["revoked"].array {
                for item in revoked {
                    self.commissionsObjects.append(Commissions(amount: item["amount"].doubleValue, rate: item["rate"].doubleValue, currency: item["currency"].stringValue, renewal: item["renewal"].int64, item: item["item"].stringValue, date: sharedDateFormatter.dateFromString(item["date"].stringValue), status: "revoked"))
                }
            }
            
            if let paid = json["paid"].array {
                for item in paid {
                    self.commissionsObjects.append(Commissions(amount: item["amount"].doubleValue, rate: item["rate"].doubleValue, currency: item["currency"].stringValue, renewal: item["renewal"].int64, item: item["item"].stringValue, date: sharedDateFormatter.dateFromString(item["date"].stringValue), status: "paid"))
                }
            }
            
            if let unpaid = json["unpaid"].array {
                for item in unpaid {
                    self.commissionsObjects.append(Commissions(amount: item["amount"].doubleValue, rate: item["rate"].doubleValue, currency: item["currency"].stringValue, renewal: item["renewal"].int64, item: item["item"].stringValue, date: sharedDateFormatter.dateFromString(item["date"].stringValue), status: "unpaid"))
                }
            }
            
            self.commissionsObjects.sortInPlace({ $0.date.compare($1.date) == NSComparisonResult.OrderedDescending })
            self.filteredCommissionsObjects = self.commissionsObjects
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    private func requestNextPage() {
//        EDDAPIWrapper.sharedInstance.requestSales([ "page": lastDownloadedPage ], success: { (json) in
//            if let items = json["sales"].array {
//                if items.count == 20 {
//                    self.hasMoreSales = true
//                } else {
//                    self.hasMoreSales = false
//                }
//                for item in items {
//                    self.sales?.append(item)
//                }
//                self.updateLastDownloadedPage()
//            }
//
//        }) { (error) in
//            print(error.localizedDescription)
//        }
    }
    
    private func updateLastDownloadedPage() {
        self.lastDownloadedPage = self.lastDownloadedPage + 1;
        sharedDefaults.setInteger(lastDownloadedPage, forKey: "\(Site.activeSite().uid)-CommissionsPage")
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
        return self.filteredCommissionsObjects.count ?? 0
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        navigationController?.pushViewController(CommissionsDetailViewController(commission: filteredCommissionsObjects[indexPath.row]), animated: true)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: Table View Delegate

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: CommissionsTableViewCell? = tableView.dequeueReusableCellWithIdentifier("CommissionsCell") as! CommissionsTableViewCell?
        
        if cell == nil {
            cell = CommissionsTableViewCell()
        }
        
        cell?.configure(filteredCommissionsObjects[indexPath.row])
        
        return cell!
    }
    
    // MARK: Segmented Control
    
    func segmentAction() {
        switch segmentedControl.selectedSegmentIndex {
            case 0:
                self.filteredCommissionsObjects = self.commissionsObjects
                reload()
            case 1:
                self.filteredCommissionsObjects = self.commissionsObjects.filter({ $0.status == "unpaid" })
                reload()
            case 2:
                self.filteredCommissionsObjects = self.commissionsObjects.filter({ $0.status == "paid" })
                reload()
            case 3:
                self.filteredCommissionsObjects = self.commissionsObjects.filter({ $0.status == "revoked" })
                reload()
            default:
                self.filteredCommissionsObjects = self.commissionsObjects
                reload()
        }
    }
    
    private func reload() {
        dispatch_async(dispatch_get_main_queue()) { 
            self.tableView.reloadData()
        }
    }
    
}

extension CommissionsViewController : InfiniteScrollingTableView {
    
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
