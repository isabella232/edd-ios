//
//  SalesFilterFetchViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 16/10/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import SwiftyJSON

private let sharedDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd"
    return formatter
}()


class SalesFilterFetchViewController: SiteTableViewController {

    fileprivate struct Data {
        var date: String
        var stat: String
    }
    
    fileprivate var dataSource = [Data]()
    
    var filter: String!
    
    var startDate: Date?
    var endDate: Date?
    
    var readableStartDate: String?
    var readableEndDate: String?
    
    var loadingView = UIView()
    
    var site: Site?
    var operation: Bool = false
    var total: Double?
    
    init(startDate: Date, endDate: Date, filter: String) {
        super.init(style: .plain)
        
        site = Site.activeSite()
        
        self.filter = filter

        self.startDate = startDate
        self.endDate = endDate
        
        sharedDateFormatter.dateFormat = "dd/MM/yyyy"
        self.readableStartDate = sharedDateFormatter.string(from: startDate)
        self.readableEndDate = sharedDateFormatter.string(from: endDate)
        sharedDateFormatter.dateFormat = "yyyyMMdd"
        
        title = "Fetching " + filter.capitalized + " Data..."
        
        view.backgroundColor = .EDDGreyColor()
        
        loadingView = {
            var frame: CGRect = self.view.frame;
            frame.origin.x = 0;
            frame.origin.y = 0;
            
            let view = UIView(frame: frame)
            view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            view.backgroundColor = .EDDGreyColor()
            
            return view
        }()
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        activityIndicator.center = view.center
        loadingView.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
        networkOperations()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.register(SalesFilterHeadingTableViewCell.self, forCellReuseIdentifier: "SalesFilterHeadingTableViewCell")
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle("Fetching " + filter.capitalized + " Data...")
        navigationItem.titleView = titleLabel
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func networkOperations() {
        self.operation = true
        view.addSubview(loadingView)
        
        EDDAPIWrapper.sharedInstance.requestStats(["type" : self.filter as AnyObject, "date" : "range" as AnyObject, "startdate" : sharedDateFormatter.string(from: startDate!) as AnyObject, "enddate" : sharedDateFormatter.string(from: endDate!) as AnyObject], success: { (json) in
            if let items = json["sales"].dictionary {
                for item in items {
                    self.dataSource.append(Data(date: item.0, stat: item.1.stringValue))
                }
                
                self.dataSource.sort{ $0.date < $1.date }
                
                self.total = json["totals"].doubleValue
                
                self.operation = true
                
                DispatchQueue.main.async(execute: {
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
                    self.dataSource.append(Data(date: item.0, stat: Site.currencyFormat(NSNumber(value: item.1.doubleValue))))
                }
                
                self.dataSource.sort{ $0.date < $1.date }
                
                self.total = json["totals"].doubleValue
                
                self.operation = true
                
                DispatchQueue.main.async(execute: {
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.operation ? 0 : (dataSource.count == 0 ? 0 : dataSource.count + 2)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Table View Data Source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "SalesFilterHeadingTableViewCell", for: indexPath) as! SalesFilterHeadingTableViewCell
            (cell as! SalesFilterHeadingTableViewCell).configure("Showing " + filter + " between " + readableStartDate! + " and " + readableEndDate!)
            return cell
        }
        
        cell = UITableViewCell(style: .value1, reuseIdentifier: "SalesFilterCell")
        cell.selectionStyle = .none
        
        if indexPath.row == 1 {
            cell.textLabel?.text = NSLocalizedString("Total " + filter + " this period", comment: "")
            cell.textLabel?.textColor = .EDDBlackColor()
            cell.textLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
            
            if filter == "earnings" {
                cell.detailTextLabel?.text = Site.currencyFormat(NSNumber(value: total!))
            } else {
                cell.detailTextLabel?.text = "\(Int(total!))"
            }

            cell.detailTextLabel?.textColor = .EDDBlackColor()
            cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
            cell.backgroundColor = .tableViewCellHighlightColor()
            return cell
        }
        
        sharedDateFormatter.dateFormat = "yyyyMMdd"
        
        let data = self.dataSource[indexPath.row - 2]
        
        let dateObject = sharedDateFormatter.date(from: data.date)
        sharedDateFormatter.dateFormat = "dd/MM/yyyy"
        cell.textLabel?.text = sharedDateFormatter.string(from: dateObject!)
        
        cell.detailTextLabel?.text = data.stat
        cell.detailTextLabel?.textColor = .EDDBlueColor()
        
        return cell
    }
    
}
