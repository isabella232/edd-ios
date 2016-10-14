//
//  FileDownloadLogsViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 22/08/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData
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

public struct Log {
    var ID: Int64!
    var userId: Int64!
    var productId: Int64!
    var productName: String!
    var customerId: Int64!
    var paymentId: Int64!
    var file: String!
    var ip: String!
    var date: NSDate!
    
}

class FileDownloadLogsViewController: SiteTableViewController, ManagedObjectContextSettable, UIViewControllerPreviewingDelegate {

    var managedObjectContext: NSManagedObjectContext!
    
    typealias JSON = SwiftyJSON.JSON
    
    var site: Site?
    var logs: JSON?
    let sharedCache = Shared.dataCache
    
    var logObjects = [Log]()
    var filteredLogObjects = [Log]()
    
    var hasMoreLogs: Bool = true {
        didSet {
            if (!hasMoreLogs) {
                activityIndicatorView.stopAnimating()
            } else {
                activityIndicatorView.startAnimating()
            }
        }
    }
    
    init(site: Site) {
        super.init(style: .Plain)
        
        self.site = site
        self.managedObjectContext = AppDelegate.sharedInstance.managedObjectContext
        
        title = NSLocalizedString("File Download Logs", comment: "File Download Logs title")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 85.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(NSLocalizedString("File Download Logs", comment: "File Download Logs title"))
        navigationItem.titleView = titleLabel
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        networkOperations()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForPreviewingWithDelegate(self, sourceView: view)
        
        sharedCache.fetch(key: Site.activeSite().uid! + "-FileDownloadLogs").onSuccess({ result in
            let json = JSON.convertFromData(result)! as JSON
            self.logs = json
            
            if let items = json["download_logs"].array {
                for item in items {
                    self.logObjects.append(Log(ID: item["ID"].int64Value, userId: item["user_id"].int64Value, productId: item["product_id"].int64Value, productName: item["product_name"].stringValue, customerId: item["customer_id"].int64Value, paymentId: item["payment_id"].int64Value, file: item["file"].stringValue, ip: item["ip"].stringValue, date: sharedDateFormatter.dateFromString(item["date"].stringValue)))
                }
            }
            
            self.logObjects.sortInPlace({ $0.date.compare($1.date) == NSComparisonResult.OrderedDescending })
            self.filteredLogObjects = self.logObjects
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        })
        
        setupInfiniteScrollView()
    }
    
    // MARK: Network Operations
    
    private func networkOperations() {
        EDDAPIWrapper.sharedInstance.requestFileDownloadLogs([:], success: { (json) in
            self.sharedCache.set(value: json.asData(), key: Site.activeSite().uid! + "-FileDownloadLogs")

            self.logObjects.removeAll(keepCapacity: false)
            
            if let items = json["download_logs"].array {
                for item in items {
                    self.logObjects.append(Log(ID: item["ID"].int64Value, userId: item["user_id"].int64Value, productId: item["product_id"].int64Value, productName: item["product_name"].stringValue, customerId: item["customer_id"].int64Value, paymentId: item["payment_id"].int64Value, file: item["file"].stringValue, ip: item["ip"].stringValue, date: sharedDateFormatter.dateFromString(item["date"].stringValue)))
                }
            }
            
            self.logObjects.sortInPlace({ $0.date.compare($1.date) == NSComparisonResult.OrderedDescending })
            self.filteredLogObjects = self.logObjects
            
            dispatch_async(dispatch_get_main_queue(), { 
                self.tableView.reloadData()
            })
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    private func requestNextPage(page: Int) {
        EDDAPIWrapper.sharedInstance.requestFileDownloadLogs([ "page": page ], success: { (json) in
            if let items = json["download_logs"].array {
                if items.count == 20 {
                    self.hasMoreLogs = true
                } else {
                    self.hasMoreLogs = false
                }
                for item in items {
                    self.logObjects.append(Log(ID: item["ID"].int64Value, userId: item["user_id"].int64Value, productId: item["product_id"].int64Value, productName: item["product_name"].stringValue, customerId: item["customer_id"].int64Value, paymentId: item["payment_id"].int64Value, file: item["file"].stringValue, ip: item["ip"].stringValue, date: sharedDateFormatter.dateFromString(item["date"].stringValue)))
                }
            } else {
                self.hasMoreLogs = false
            }
            
            self.logObjects.sortInPlace({ $0.date.compare($1.date) == NSComparisonResult.OrderedDescending })
            self.filteredLogObjects = self.logObjects
            
            dispatch_async(dispatch_get_main_queue(), { 
                self.tableView.reloadData()
            })
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    
    // MARK: Table View Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredLogObjects.count ?? 0
    }
    
    // MARK: Table View Delegate
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: FileDownloadLogsTableViewCell? = tableView.dequeueReusableCellWithIdentifier("FileDownloadLogCell") as! FileDownloadLogsTableViewCell?
        
        if cell == nil {
            cell = FileDownloadLogsTableViewCell()
        }
    
        cell!.configure(filteredLogObjects[indexPath.row])
        
        cell!.layout()
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let logData = filteredLogObjects[indexPath.row]
        navigationController?.pushViewController(FileDownloadLogsDetailViewController(log: logData), animated: true)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: 3D Touch
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRowAtPoint(location) {
            previewingContext.sourceRect = tableView.rectForRowAtIndexPath(indexPath)
            let logData = filteredLogObjects[indexPath.row]
            return FileDownloadLogsDetailViewController(log: logData)
        }
        return nil
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }

}

extension FileDownloadLogsViewController: InfiniteScrollingTableView {
    
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
