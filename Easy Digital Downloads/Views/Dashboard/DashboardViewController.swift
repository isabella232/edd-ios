//
//  DashboardViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 22/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON

let estimatedHeight: CGFloat = 150
let reuseIdentifier: String = "dashboardCell"

class DashboardViewController: SiteTableViewController, ManagedObjectContextSettable {
    
    var managedObjectContext: NSManagedObjectContext!
    
    var site: Site?
    var cells: NSArray = [
        ["title": NSLocalizedString("Sales", comment: ""), "type": 1],
        ["title": NSLocalizedString("Earnings", comment: ""), "type": 2],
        ["title": NSLocalizedString("Commissions", comment: ""), "type": 3],
        ["title": NSLocalizedString("Reviews", comment: ""), "type": 4],
    ]
    var stats: Stats?
    var salesGraphDates: Array<String> = []
    var salesGraphData: Array<Int> = []
    var earningsGraphDates: Array<String> = []
    var earningsGraphData: Array<Double> = []
    
    init(site: Site) {
        super.init(style: .Plain)

        self.site = site

        title = NSLocalizedString("Dashboard", comment: "Dashboard title")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = estimatedHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        EDDAPIWrapper.sharedInstance.requestStats([:], success: { (json) in
            let earnings = NSDictionary(dictionary: json["stats"]["earnings"].dictionaryObject!)
            let sales = NSDictionary(dictionary: json["stats"]["sales"].dictionaryObject!)
            self.stats = Stats(sales: sales, earnings: earnings, updatedAt: NSDate())
            self.tableView.reloadData()
            }) { (error) in
                fatalError()
        }
        
        EDDAPIWrapper.sharedInstance.requestSalesStatsGraphData({ json in
            self.processSalesGraphData(json)
            self.tableView.reloadData()
        }) { (error) in
            fatalError()
        }
        
        EDDAPIWrapper.sharedInstance.requestEarningsStatsGraphData({ json in
            self.processEarningsGraphData(json)
            self.tableView.reloadData()
            }) { (error) in
                fatalError()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        view.backgroundColor = .EDDGreyColor()
        tableView.backgroundColor = .EDDGreyColor()
        
        tableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        tableView.registerClass(DashboardTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.bounces = true
        tableView.separatorStyle = .None
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(DashboardViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl = refreshControl
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        if refreshControl.refreshing {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                    refreshControl.performSelector(#selector(refreshControl.endRefreshing), withObject: nil, afterDelay: 0.05)
                })
            })
        }
    }
    
    private func setupTableView() {
    }
    
    private func processSalesGraphData(json: JSON) {
//        let sales = NSDictionary(dictionary: json["sales"].dictionaryObject!) as! Dictionary<String, AnyObject>
        let sales = json["sales"].dictionaryObject
        
        let keys = sales?.keys
        let sorted = keys?.sort {
            return $0 < $1
        }
        
        var salesGraphData: Array<Int> = []
        for key in sorted! {
            salesGraphData.append(sales![key]!.integerValue)
            let dateRange = Range(start: key.endIndex.advancedBy(-2), end: key.endIndex)
            let monthRange = Range(start: key.startIndex.advancedBy(4), end: key.startIndex.advancedBy(6))
            
            let date = key[dateRange]
            let month = Int(key[monthRange])
            
            let dateFormatter: NSDateFormatter = NSDateFormatter()
            let months = dateFormatter.shortMonthSymbols
            let monthSymbol = months[month!-1] 
            
            let dateString = "\(date) \(monthSymbol)"
            
            self.salesGraphDates.append(dateString)
        }
        
        self.salesGraphData = salesGraphData
    }

    private func processEarningsGraphData(json: JSON) {
        let earnings = json["earnings"].dictionaryObject
        
        let keys = earnings?.keys
        let sorted = keys?.sort {
            return $0 < $1
        }
        
        var earningsGraphData: Array<Double> = []
        for key in sorted! {
            earningsGraphData.append(earnings![key]!.doubleValue)
            let dateRange = Range(start: key.endIndex.advancedBy(-2), end: key.endIndex)
            let monthRange = Range(start: key.startIndex.advancedBy(4), end: key.startIndex.advancedBy(6))
            
            let date = key[dateRange]
            let month = Int(key[monthRange])
            
            let dateFormatter: NSDateFormatter = NSDateFormatter()
            let months = dateFormatter.shortMonthSymbols
            let monthSymbol = months[month!-1]
            
            let dateString = "\(date) \(monthSymbol)"
            
            self.earningsGraphDates.append(dateString)
        }
        
        self.earningsGraphData = earningsGraphData
    }

    
    // MARK: Table View Delegate
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch site!.typeEnum  {
            case SiteType.Standard:
                return 2
            case SiteType.Commission:
                return 2
            case SiteType.StandardCommission, SiteType.StandardStore:
                return 2
            default:
                return 2
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150
    }
    
    // MARK: Table View Data Source
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: DashboardTableViewCell? = tableView.dequeueReusableCellWithIdentifier("dashboardCell") as! DashboardTableViewCell?
        
        if cell == nil {
            cell = DashboardTableViewCell()
        }
        
        let config = (cells.objectAtIndex(indexPath.row) as? NSDictionary)!
        
        switch config["type"] as! Int {
            case 1:
                cell!.configure(config, stats: stats, data: salesGraphData, dates: salesGraphDates)
                break
            case 2:
                cell!.configure(config, stats: stats, data: earningsGraphData, dates: earningsGraphDates)
                break
            default:
                break
        }
        
        cell!.layout()
        
        return cell!
    }

}