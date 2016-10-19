//
//  CommissionsDetailViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 29/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON

private let sharedDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}()

class CommissionsDetailViewController: SiteTableViewController {

    private enum CellType {
        case MetaHeading
        case Meta
    }
    
    private var cells = [CellType]()
    
    var site: Site?
    var commission: Commissions?
    
    init(commission: Commissions) {
        super.init(style: .Plain)
        
        self.site = Site.activeSite()
        self.commission = commission
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(NSLocalizedString("Commission", comment: ""))
        navigationItem.titleView = titleLabel
        
        tableView.registerClass(CommissionsDetailHeadingTableViewCell.self, forCellReuseIdentifier: "CommissionsDetailHeadingTableViewCell")
        tableView.registerClass(CommissionsDetailMetaTableViewCell.self, forCellReuseIdentifier: "CommissionsDetailMetaTableViewCell")
        
        cells = [.MetaHeading, .Meta]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Table View Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    // MARK: Table View Delegate
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        switch cells[indexPath.row] {
            case .MetaHeading:
                cell = tableView.dequeueReusableCellWithIdentifier("CommissionsDetailHeadingTableViewCell", forIndexPath: indexPath) as! CommissionsDetailHeadingTableViewCell
                (cell as! CommissionsDetailHeadingTableViewCell).configure("Meta")
            case .Meta:
                cell = tableView.dequeueReusableCellWithIdentifier("CommissionsDetailMetaTableViewCell", forIndexPath: indexPath) as! CommissionsDetailMetaTableViewCell
        }
        
        return cell!
    }
    
}
