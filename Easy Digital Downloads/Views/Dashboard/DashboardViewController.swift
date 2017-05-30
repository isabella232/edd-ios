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
import WatchConnectivity

let estimatedHeight: CGFloat = 150
let reuseIdentifier: String = "dashboardCell"

class DashboardViewController: SiteTableViewController, ManagedObjectContextSettable {
    
    var managedObjectContext: NSManagedObjectContext!
    
    fileprivate enum CellType {
        case sales
        case earnings
        case commissions
        case storeCommissions
    }
    
    fileprivate var cells = [CellType]()
    
    var site: Site?

    let sharedDefaults: UserDefaults = UserDefaults(suiteName: "group.easydigitaldownloads.EDDSalesTracker")!

    var cachedGraphData: GraphData?
    var stats: Stats?
    var commissionsStats: NSDictionary?
    var salesGraphDates: Array<String> = []
    var salesGraphData: Array<Int> = []
    var earningsGraphDates: Array<String> = []
    var earningsGraphData: Array<Double> = []
    var storeCommission: String?
    
    init(site: Site) {
        super.init(style: .plain)
        
        self.site = site
        
        title = NSLocalizedString("Dashboard", comment: "Dashboard title")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = estimatedHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(NSLocalizedString("Dashboard", comment: "Dashboard title"))
        
        navigationItem.titleView = titleLabel
        
        cells = [.sales, .earnings]
        
        if ((site.hasCommissions) != false && sharedDefaults.bool(forKey: Site.activeSite().uid! + "-DisplayCommissions") == true) {
            cells.append(.commissions)
            cells.append(.storeCommissions)
        }
        
        topLayoutAnchor = -10.0
        
        // Setup WatchKit Session
        if WCSession.isSupported() {
            let watchSession = WCSession.default()
            watchSession.delegate = self
            watchSession.activate()
            if watchSession.isPaired && watchSession.isWatchAppInstalled {
                do {
                    let userInfo = [
                        "activeSiteName": Site.activeSite().name!,
                        "activeSiteURL" : Site.activeSite().url!,
                        "activeSiteKey" : Site.activeSite().key,
                        "activeSiteToken" : Site.activeSite().token,
                        "activeSiteCurrency" : Site.activeSite().currency!
                    ]
                    try watchSession.transferUserInfo(userInfo)
                } catch let error as NSError {
                    print(error.description)
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !UserDefaults.standard.bool(forKey: "DashboardLoaded") {
            super.animateTable()
            UserDefaults.standard.set(true, forKey: "DashboardLoaded")
        }
        
        if Stats.hasStatsForActiveSite() {
            processCachedStats()
        }
        
        if GraphData.hasGraphDataForActiveSite() {
            processCachedGraphData()
        }
        
        if Stats.hasStatsForActiveSite() || GraphData.hasGraphDataForActiveSite() {
            tableView.reloadData()
        }
        
        networkOperations()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.leftBarButtonItem = true
        
        setupTableView()
        
        view.backgroundColor = .EDDGreyColor()
        tableView.backgroundColor = .EDDGreyColor()
        
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.register(DashboardTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.bounces = true
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(DashboardViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl = refreshControl
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    func handleRefresh(_ refreshControl: UIRefreshControl) {
        if refreshControl.isRefreshing {
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
                DispatchQueue.main.async(execute: {
                    self.networkOperations()
                    self.tableView.reloadData()
                    refreshControl.perform(#selector(refreshControl.endRefreshing), with: nil, afterDelay: 0.05)
                })
            })
        }
    }
    
    fileprivate func setupTableView() {
    }
    
    // MARK: Table View Delegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    // MARK: Table View Data Source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: DashboardTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "dashboardCell") as! DashboardTableViewCell?
        
        if cell == nil {
            cell = DashboardTableViewCell()
        }
        
        cell?.selectionStyle = .none
        
        switch cells[indexPath.row] {
            case .sales:
                cell!.configure("Sales Today", stats: stats, data: salesGraphData, dates: salesGraphDates)
                break
            case .earnings:
                cell!.configure("Earnings Today", stats: stats, data: earningsGraphData, dates: earningsGraphDates)
                break
            case .commissions:
                cell!.configureStaticCell("Commissions", data: commissionsStats)
                break
            case .storeCommissions:
                cell!.configureSmallStaticCell("Store Commissions", cellStat: storeCommission)
                break
        }
        
        cell!.layout()
        
        return cell!
    }
    
    // MARK: Buttons
    
    func editDashboardButtonPressed() {
        let editDashboardViewController = EditDashboardLayoutViewController(site: self.site!)
        editDashboardViewController.view.backgroundColor = .clear
        editDashboardViewController.modalPresentationStyle = .overFullScreen
        editDashboardViewController.modalPresentationCapturesStatusBarAppearance = true
        present(editDashboardViewController, animated: true, completion: nil)
    }
    
    // MARK: Loading
    
    fileprivate func networkOperations() {
        let networkOperationGroup = DispatchGroup()
        
        networkOperationGroup.enter()
        
        var sales: NSDictionary = NSDictionary()
        var earnings: NSDictionary = NSDictionary()
        
        EDDAPIWrapper.sharedInstance.requestStats([:], success: { (json) in
            earnings = NSDictionary(dictionary: json["stats"]["earnings"].dictionaryObject!)
            sales = NSDictionary(dictionary: json["stats"]["sales"].dictionaryObject!)
            
            self.tableView.reloadData()
            networkOperationGroup.leave()
        }) { (error) in
            NSLog(error.localizedDescription)
        }
        
        networkOperationGroup.enter()
        
        EDDAPIWrapper.sharedInstance.requestSalesStatsGraphData({ json in
            self.processSalesGraphData(json)
            self.tableView.reloadData()
            networkOperationGroup.leave()
        }) { (error) in
            NSLog(error.localizedDescription)
        }
        
        networkOperationGroup.enter()
        
        EDDAPIWrapper.sharedInstance.requestEarningsStatsGraphData({ json in
            self.processEarningsGraphData(json)
            self.tableView.reloadData()
            networkOperationGroup.leave()
        }) { (error) in
            NSLog(error.localizedDescription)
        }
        
        if (Site.activeSite().hasCommissions == true && sharedDefaults.bool(forKey: Site.activeSite().uid! + "-DisplayCommissions") == true) {
            networkOperationGroup.enter()
            
            EDDAPIWrapper.sharedInstance.requestCommissions([:], success: { (json) in
                self.commissionsStats = NSDictionary(dictionary: json["totals"].dictionaryObject!)
                self.tableView.reloadData()
                networkOperationGroup.leave()
            }) { (error) in
                NSLog(error.localizedDescription)
            }
            
            networkOperationGroup.enter()
            
            EDDAPIWrapper.sharedInstance.requestStoreCommissions([:], success: { (json) in
                self.storeCommission = json["total_unpaid"].stringValue
                self.tableView.reloadData()
                networkOperationGroup.leave()
            }) { (error) in
                NSLog(error.localizedDescription)
            }
        }
        
        networkOperationGroup.notify(queue: DispatchQueue.main) {
            if self.site?.hasCommissions != nil {
                self.stats = Stats(sales: sales, earnings: earnings, commissions: NSDictionary(), storeCommissions: ["storeCommissions": ""], updatedAt: Date())
                Stats.encode(self.stats!)
            } else {
                self.stats = Stats(sales: sales, earnings: earnings, commissions: self.commissionsStats!, storeCommissions: ["storeCommissions": self.storeCommission!], updatedAt: Date())
                Stats.encode(self.stats!)
            }
            self.cachedGraphData = GraphData(salesGraphDates: self.salesGraphDates, salesGraphData: self.salesGraphData, earningsGraphDates: self.earningsGraphDates, earningsGraphData: self.earningsGraphData)
            
            GraphData.encode(self.cachedGraphData!)
            self.tableView.reloadData()
        }
    }
    
    func showActivityIndicator() {
        

    }
    
    // MARK: Stats
    
    fileprivate func processCachedStats() {
        self.stats = Stats.decode()
        tableView.reloadData()
    }
    
    fileprivate func processCachedGraphData() {
        guard let data = GraphData.decode() else {
            return
        }
        
        self.salesGraphData = data.salesGraphData
        self.salesGraphDates = data.salesGraphDates
        self.earningsGraphData = data.earningsGraphData
        self.earningsGraphDates = data.earningsGraphDates
    }
    
    fileprivate func processSalesGraphData(_ json: JSON) {
        let sales = json["sales"].dictionaryObject
        
        let keys = sales?.keys
        let sorted = keys?.sorted {
            return $0 < $1
        }
        
        var salesGraphData: Array<Int> = []
        for key in sorted! {
            salesGraphData.append((sales![key]! as AnyObject).integerValue)
            
            let dateR = key.endIndex.advancedBy(-2) ..< key.endIndex
            let dateRange = Range(dateR)
            
            let monthR = key.startIndex.advancedBy(4) ..< key.startIndex.advancedBy(6)
            let monthRange = Range(monthR)
            
            let date = key[dateRange]
            let month = Int(key[monthRange])
            
            let dateFormatter: DateFormatter = NSDateFormatter()
            let months = dateFormatter.shortMonthSymbols
            let monthSymbol = months[month!-1]
            
            let dateString = "\(date) \(monthSymbol)"
            
            self.salesGraphDates.append(dateString)
        }
        
        self.salesGraphData = salesGraphData
    }
    
    fileprivate func processEarningsGraphData(_ json: JSON) {
        let earnings = json["earnings"].dictionaryObject
        
        let keys = earnings?.keys
        let sorted = keys?.sorted {
            return $0 < $1
        }
        
        var earningsGraphData: Array<Double> = []
        for key in sorted! {
            earningsGraphData.append((earnings![key]! as AnyObject).doubleValue)
            let dateR = key.endIndex.advancedBy(-2) ..< key.endIndex
            let dateRange = Range(dateR)
            
            let monthR = key.startIndex.advancedBy(4) ..< key.startIndex.advancedBy(6)
            let monthRange = Range(monthR)
            
            let date = key[dateRange]
            let month = Int(key[monthRange])
            
            let dateFormatter: DateFormatter = NSDateFormatter()
            let months = dateFormatter.shortMonthSymbols
            let monthSymbol = months[month!-1]
            
            let dateString = "\(date) \(monthSymbol)"
            
            self.earningsGraphDates.append(dateString)
        }
        
        self.earningsGraphData = earningsGraphData
    }

}

extension DashboardViewController: WCSessionDelegate {

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }

    func sessionDidDeactivate(_ session: WCSession) {
        
    }

}
