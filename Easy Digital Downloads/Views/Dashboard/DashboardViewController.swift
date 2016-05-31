//
//  DashboardViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 22/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData

let estimatedHeight: CGFloat = 150
let reuseIdentifier: String = "dashboardCell"

class DashboardViewController: SiteTableViewController, ManagedObjectContextSettable {
    
    var managedObjectContext: NSManagedObjectContext!
    
    var site: Site?
    var cells:NSDictionary = [
        "sales" : ["title": NSLocalizedString("Sales", comment: ""), "type": 1],
        "earnings" : ["title": NSLocalizedString("Earnings", comment: ""), "type": 2],
        "commissions" : ["title": NSLocalizedString("Commissions", comment: ""), "type": 3],
        "reviews" : ["title": NSLocalizedString("Reviews", comment: ""), "type": 4],
    ]
    
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        NSLog("Dashboard loaded")
        
        view.backgroundColor = .EDDGreyColor()
        tableView.backgroundColor = .EDDGreyColor()
        
        tableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        tableView.registerClass(DashboardTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.bounces = true
        tableView.separatorStyle = .None
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(DashboardViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl = refreshControl
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    private func setupTableView() {
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
                return 1
            case SiteType.StandardCommission, SiteType.StandardStore:
                return 4
            default:
                return 3
        }
    }
    
    // MARK: Table View Data Source
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = DashboardTableViewCell()
        
        cell.title = "Sales"
        cell.stat = "$20"
        
        return cell
    }
}