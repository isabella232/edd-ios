//
//  SalesFilterFetchViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 16/10/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import SwiftyJSON

private let sharedDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    formatter.dateFormat = "yyyyMMdd"
    return formatter
}()


class SalesFilterFetchViewController: SiteTableViewController {

    var startDate: NSDate?
    var endDate: NSDate?
    
    var readableStartDate: String?
    var readableEndDate: String?
    
    var loadingView = UIView()
    
    var site: Site?
    var operation: Bool = false
    var data: [[String: JSON]] = [[String: JSON]]()
    var keys: [String] = [String]()
    var stats: [JSON] = [JSON]()
    var total: Int64?
    
    init(startDate: NSDate, endDate: NSDate) {
        super.init(style: .Plain)
        
        site = Site.activeSite()

        self.startDate = startDate
        self.endDate = endDate
        
        sharedDateFormatter.dateFormat = "dd/MM/yyyy"
        self.readableStartDate = sharedDateFormatter.stringFromDate(startDate)
        self.readableEndDate = sharedDateFormatter.stringFromDate(endDate)
        sharedDateFormatter.dateFormat = "yyyyMMdd"
        
        title = NSLocalizedString("Fetching Sales Data...", comment: "")
        
        view.backgroundColor = .EDDGreyColor()
        
        loadingView = {
            var frame: CGRect = self.view.frame;
            frame.origin.x = 0;
            frame.origin.y = 0;
            
            let view = UIView(frame: frame)
            view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
            view.backgroundColor = .EDDGreyColor()
            
            return view
        }()
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleBottomMargin]
        activityIndicator.center = view.center
        loadingView.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
        networkOperations()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.registerClass(SalesFilterHeadingTableViewCell.self, forCellReuseIdentifier: "SalesFilterHeadingTableViewCell")
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(NSLocalizedString("Fetching Sales Data...", comment: ""))
        navigationItem.titleView = titleLabel
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func networkOperations() {
        self.operation = true
        view.addSubview(loadingView)
        
        EDDAPIWrapper.sharedInstance.requestStats(["type" : "sales", "date" : "range", "startdate" : sharedDateFormatter.stringFromDate(startDate!), "enddate" : sharedDateFormatter.stringFromDate(endDate!)], success: { (json) in
            if let items = json["sales"].dictionary {
                for (key, value) in json["sales"] {
                    let object = [key: value]
                    self.data.append(object)
                }
                
                for item in items {
                    self.keys.append(item.0)
                    self.stats.append(item.1)
                }
                
                self.total = json["totals"].int64Value
                
                self.operation = true
                
                dispatch_async(dispatch_get_main_queue(), {
                    let titleLabel = ViewControllerTitleLabel()
                    titleLabel.setTitle(NSLocalizedString("Filtered Sales", comment: ""))
                    self.navigationItem.titleView = titleLabel
                    
                    self.operation = false
                    self.loadingView.removeFromSuperview()
                    self.tableView.reloadData()
                })
            }
        }) { (error) in
            NSLog(error.localizedDescription)
        }
    }
    
    // MARK: Table View Delegate

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.operation ? 0 : (data.count == 0 ? 0 : data.count + 2)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: Table View Data Source
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("SalesFilterHeadingTableViewCell", forIndexPath: indexPath) as! SalesFilterHeadingTableViewCell
            (cell as! SalesFilterHeadingTableViewCell).configure("Showing sales between " + readableStartDate! + " and " + readableEndDate!)
            return cell
        }
        
        cell = UITableViewCell(style: .Value1, reuseIdentifier: "SalesFilterCell")
        cell.selectionStyle = .None
        
        if indexPath.row == 1 {
            cell.textLabel?.text = NSLocalizedString("Total sales this period", comment: "")
            cell.detailTextLabel?.text = "\(total!)"
            cell.backgroundColor = .tableViewCellHighlightColor()
            return cell
        }
        
        sharedDateFormatter.dateFormat = "yyyyMMdd"
        let dateObject = sharedDateFormatter.dateFromString(self.keys[indexPath.row - 2])
        sharedDateFormatter.dateFormat = "dd/MM/yyyy"
        cell.textLabel?.text = sharedDateFormatter.stringFromDate(dateObject!)
        
        cell.detailTextLabel?.text = self.stats[indexPath.row - 2].stringValue
        
        return cell
    }
    
}
