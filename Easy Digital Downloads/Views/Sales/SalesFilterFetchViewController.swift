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
    formatter.dateFormat = "yyyyMMdd"
    return formatter
}()


class SalesFilterFetchViewController: SiteTableViewController {

    private struct Data {
        var date: String
        var stat: String
    }
    
    private var dataSource = [Data]()
    
    var filter: String!
    
    var startDate: NSDate?
    var endDate: NSDate?
    
    var readableStartDate: String?
    var readableEndDate: String?
    
    var loadingView = UIView()
    
    var site: Site?
    var operation: Bool = false
    var total: Double?
    
    init(startDate: NSDate, endDate: NSDate, filter: String) {
        super.init(style: .Plain)
        
        site = Site.activeSite()
        
        self.filter = filter

        self.startDate = startDate
        self.endDate = endDate
        
        sharedDateFormatter.dateFormat = "dd/MM/yyyy"
        self.readableStartDate = sharedDateFormatter.stringFromDate(startDate)
        self.readableEndDate = sharedDateFormatter.stringFromDate(endDate)
        sharedDateFormatter.dateFormat = "yyyyMMdd"
        
        title = "Fetching " + filter.capitalizedString + " Data..."
        
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
        titleLabel.setTitle("Fetching " + filter.capitalizedString + " Data...")
        navigationItem.titleView = titleLabel
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func networkOperations() {
        self.operation = true
        view.addSubview(loadingView)
        
        EDDAPIWrapper.sharedInstance.requestStats(["type" : self.filter, "date" : "range", "startdate" : sharedDateFormatter.stringFromDate(startDate!), "enddate" : sharedDateFormatter.stringFromDate(endDate!)], success: { (json) in
            if let items = json["sales"].dictionary {
                for item in items {
                    self.dataSource.append(Data(date: item.0, stat: item.1.stringValue))
                }
                
                self.dataSource.sortInPlace{ $0.date < $1.date }
                
                self.total = json["totals"].doubleValue
                
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
            
            if let items = json["earnings"].dictionary {
                for item in items {
                    self.dataSource.append(Data(date: item.0, stat: Site.currencyFormat(item.1.doubleValue)))
                }
                
                self.dataSource.sortInPlace{ $0.date < $1.date }
                
                self.total = json["totals"].doubleValue
                
                self.operation = true
                
                dispatch_async(dispatch_get_main_queue(), {
                    let titleLabel = ViewControllerTitleLabel()
                    titleLabel.setTitle(NSLocalizedString("Filtered Earnings", comment: ""))
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
        return self.operation ? 0 : (dataSource.count == 0 ? 0 : dataSource.count + 2)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: Table View Data Source
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("SalesFilterHeadingTableViewCell", forIndexPath: indexPath) as! SalesFilterHeadingTableViewCell
            (cell as! SalesFilterHeadingTableViewCell).configure("Showing " + filter + " between " + readableStartDate! + " and " + readableEndDate!)
            return cell
        }
        
        cell = UITableViewCell(style: .Value1, reuseIdentifier: "SalesFilterCell")
        cell.selectionStyle = .None
        
        if indexPath.row == 1 {
            cell.textLabel?.text = NSLocalizedString("Total " + filter + " this period", comment: "")
            cell.textLabel?.textColor = .EDDBlackColor()
            cell.textLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
            
            if filter == "earnings" {
                cell.detailTextLabel?.text = Site.currencyFormat(total!)
            } else {
                cell.detailTextLabel?.text = "\(total!)"
            }

            cell.detailTextLabel?.textColor = .EDDBlackColor()
            cell.detailTextLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
            cell.backgroundColor = .tableViewCellHighlightColor()
            return cell
        }
        
        sharedDateFormatter.dateFormat = "yyyyMMdd"
        
        let data = self.dataSource[indexPath.row - 2]
        
        let dateObject = sharedDateFormatter.dateFromString(data.date)
        sharedDateFormatter.dateFormat = "dd/MM/yyyy"
        cell.textLabel?.text = sharedDateFormatter.stringFromDate(dateObject!)
        
        cell.detailTextLabel?.text = data.stat
        
        return cell
    }
    
}
