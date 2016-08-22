//
//  MoreViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 18/08/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData

class MoreViewController: UITableViewController, ManagedObjectContextSettable {

    var managedObjectContext: NSManagedObjectContext!
    
    var site: Site?

    let section0Cells = [
        [
            "title": "Site Information",
        ],
        [
            "title": "Manage Sites"
        ]
    ]

    let section1Cells = [
        [
            "title": "Commissions"
        ],
        [
            "title": "Store Commissions"
        ]
    ]
    
    let section2Cells = [
        [
            "title": "File Download Logs"
        ]
    ]
    
    let section3Cells = [
        [
            "title": "Reviews"
        ]
    ]
    
    init(site: Site) {
        super.init(style: .Plain)
        
        self.site = site
        
        title = NSLocalizedString("More", comment: "More View Controller title")
        tableView.scrollEnabled = true
        tableView.bounces = true
        tableView.showsVerticalScrollIndicator = true
        tableView.userInteractionEnabled = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = estimatedHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Table View Delegate

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (Site.activeSite().hasReviews != nil) {
            return 4
        } else {
            return 3
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else if section == 1 {
            return 2
        } else {
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "General"
        } else if section == 1 {
            return "Commissions"
        } else if section == 2 {
            return "Logs"
        } else if section == 3 {
            return "Integrations"
        } else {
            return nil
        }
    }
    
    // MARK: Table View Data Source

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MoreCell")
        
        if (cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "MoreCell")
        }
        
        if indexPath.section == 0 {
            cell?.textLabel?.text = section0Cells[indexPath.row]["title"]
        } else if indexPath.section == 1 {
            cell?.textLabel?.text = section1Cells[indexPath.row]["title"]
        } else if indexPath.section == 2 {
            cell?.textLabel?.text = section2Cells[indexPath.row]["title"]
        } else if indexPath.section == 3 {
            cell?.textLabel?.text = section3Cells[indexPath.row]["title"]
        }
        
        return cell!
    }
    
}
