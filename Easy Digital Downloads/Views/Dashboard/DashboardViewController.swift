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
        ["title": NSLocalizedString("Store Commissions", comment: ""), "type": 4],
        ["title": NSLocalizedString("Reviews", comment: ""), "type": 5],
    ]
    var cachedGraphData: GraphData?
    var stats: Stats?
    var commissionsStats: NSDictionary?
    var salesGraphDates: Array<String> = []
    var salesGraphData: Array<Int> = []
    var earningsGraphDates: Array<String> = []
    var earningsGraphData: Array<Double> = []
    var storeCommission: String?
    
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
        
        if Stats.hasStatsForActiveSite() {
            processCachedStats()
        }
        
        if GraphData.hasGraphDataForActiveSite() {
            processCachedGraphData()
        }
        
        self.tableView.reloadData()
        
        let networkOperationGroup = dispatch_group_create()
        
        dispatch_group_enter(networkOperationGroup)
        
        var sales: NSDictionary = NSDictionary()
        var earnings: NSDictionary = NSDictionary()
        
        EDDAPIWrapper.sharedInstance.requestStats([:], success: { (json) in
            earnings = NSDictionary(dictionary: json["stats"]["earnings"].dictionaryObject!)
            sales = NSDictionary(dictionary: json["stats"]["sales"].dictionaryObject!)
            
            self.tableView.reloadData()
            dispatch_group_leave(networkOperationGroup)
            }) { (error) in
                fatalError()
        }
        
        dispatch_group_enter(networkOperationGroup)
        
        EDDAPIWrapper.sharedInstance.requestSalesStatsGraphData({ json in
            self.processSalesGraphData(json)
            self.tableView.reloadData()
            dispatch_group_leave(networkOperationGroup)
        }) { (error) in
            fatalError()
        }
        
        dispatch_group_enter(networkOperationGroup)
        
        EDDAPIWrapper.sharedInstance.requestEarningsStatsGraphData({ json in
            self.processEarningsGraphData(json)
            self.tableView.reloadData()
            dispatch_group_leave(networkOperationGroup)
            }) { (error) in
                fatalError()
        }
        
        dispatch_group_enter(networkOperationGroup)
        
        EDDAPIWrapper.sharedInstance.requestCommissions([:], success: { (json) in
            self.commissionsStats = NSDictionary(dictionary: json["totals"].dictionaryObject!)
            self.tableView.reloadData()
            dispatch_group_leave(networkOperationGroup)
            }) { (error) in
                fatalError()
        }
        
        dispatch_group_enter(networkOperationGroup)
        
        EDDAPIWrapper.sharedInstance.requestStoreCommissions([:], success: { (json) in
            self.storeCommission = json["total_unpaid"].stringValue
            self.tableView.reloadData()
            dispatch_group_leave(networkOperationGroup)
        }) { (error) in
            fatalError()
        }
        
        dispatch_group_notify(networkOperationGroup, dispatch_get_main_queue()) {
            self.stats = Stats(sales: sales, earnings: earnings, commissions: self.commissionsStats!, storeCommissions: ["storeCommissions": self.storeCommission!], updatedAt: NSDate())
            self.cachedGraphData = GraphData(salesGraphDates: self.salesGraphDates, salesGraphData: self.salesGraphData, earningsGraphDates: self.earningsGraphDates, earningsGraphData: self.earningsGraphData)
            Stats.encode(self.stats!)
            GraphData.encode(self.cachedGraphData!)
            self.tableView.reloadData()
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
        
        let rightNavigationItemImage = UIImage(named: "NavigationBar-EditLayout")
        let rightNavigationItemButton = HighlightButton(type: .Custom)
        rightNavigationItemButton.tintColor = .whiteColor()
        rightNavigationItemButton.setImage(rightNavigationItemImage, forState: .Normal)
        rightNavigationItemButton.addTarget(self, action: #selector(DashboardViewController.editDashboardButtonPressed), forControlEvents: .TouchUpInside)
        rightNavigationItemButton.sizeToFit()
        
        let rightNavigationBarButton = UIBarButtonItem(customView: rightNavigationItemButton)
        rightNavigationBarButton.accessibilityIdentifier = "Edit Layout"
        
        navigationItem.rightBarButtonItems = [rightNavigationBarButton]
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
    
    // MARK: Table View Delegate
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4;
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
        
        cell?.selectionStyle = .None
        
        let config = (cells.objectAtIndex(indexPath.row) as? NSDictionary)!
        
        switch config["type"] as! Int {
            case 1:
                cell!.configure(config, stats: stats, data: salesGraphData, dates: salesGraphDates)
                break
            case 2:
                cell!.configure(config, stats: stats, data: earningsGraphData, dates: earningsGraphDates)
                break
            case 3:
                cell!.configureStaticCell(config, data: commissionsStats)
                break
            case 4:
                cell!.configureSmallStaticCell(config, cellStat: storeCommission)
                break
            default:
                break
        }
        
        cell!.layout()
        
        return cell!
    }
    
    // MARK: Buttons
    
    func editDashboardButtonPressed() {
        let editDashboardViewController = EditDashboardLayoutViewController(site: self.site!)
        editDashboardViewController.view.backgroundColor = .clearColor()
        editDashboardViewController.modalPresentationStyle = .OverFullScreen
        editDashboardViewController.modalPresentationCapturesStatusBarAppearance = true
        presentViewController(editDashboardViewController, animated: true, completion: nil)
    }
    
    // MARK: Loading
    
    func showActivityIndicator() {
        

    }
    
    // MARK: Stats
    
    private func processCachedStats() {
        stats = Stats.decode()
    }
    
    private func processCachedGraphData() {
        guard let data = GraphData.decode() else {
            return
        }
        
        self.salesGraphData = data.salesGraphData
        self.salesGraphDates = data.salesGraphDates
        self.earningsGraphData = data.earningsGraphData
        self.earningsGraphDates = data.earningsGraphDates
    }
    
    private func processSalesGraphData(json: JSON) {
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

}