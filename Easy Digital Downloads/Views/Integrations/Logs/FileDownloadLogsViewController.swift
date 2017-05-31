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

private let sharedDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
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
    var date: Date!
    
}

class FileDownloadLogsViewController: SiteTableViewController, ManagedObjectContextSettable, UIViewControllerPreviewingDelegate {

    var managedObjectContext: NSManagedObjectContext!
    
    typealias JSON = SwiftyJSON.JSON
    
    var site: Site?
    var logs: JSON?
    let sharedCache = Shared.dataCache
    
    var operation = false
    
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
    
    var lastDownloadedPage = 1
    
    init(site: Site) {
        super.init(style: .plain)
        
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
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        networkOperations()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForPreviewing(with: self, sourceView: view)
        
        sharedCache.fetch(key: Site.activeSite().uid! + "-FileDownloadLogs").onSuccess({ result in
            let json = JSON.convertFromData(result)! as JSON
            self.logs = json
            
            if let items = json["download_logs"].array {
                for item in items {
                    self.logObjects.append(Log(ID: item["ID"].int64Value, userId: item["user_id"].int64Value, productId: item["product_id"].int64Value, productName: item["product_name"].stringValue, customerId: item["customer_id"].int64Value, paymentId: item["payment_id"].int64Value, file: item["file"].stringValue, ip: item["ip"].stringValue, date: sharedDateFormatter.date(from: item["date"].stringValue)))
                }
            }
            
            self.logObjects.sort(by: { $0.date.compare($1.date) == ComparisonResult.orderedDescending })
            self.filteredLogObjects = self.logObjects
            
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        })
        
        setupInfiniteScrollView()
    }
    
    // MARK: Network Operations
    
    fileprivate func networkOperations() {
        if (operation) {
            return
        }
        
        operation = true
        
        EDDAPIWrapper.sharedInstance.requestFileDownloadLogs([:], success: { (json) in
            self.sharedCache.set(value: json.asData(), key: Site.activeSite().uid! + "-FileDownloadLogs")

            self.logObjects.removeAll(keepingCapacity: false)
            
            if let items = json["download_logs"].array {
                for item in items {
                    self.logObjects.append(Log(ID: item["ID"].int64Value, userId: item["user_id"].int64Value, productId: item["product_id"].int64Value, productName: item["product_name"].stringValue, customerId: item["customer_id"].int64Value, paymentId: item["payment_id"].int64Value, file: item["file"].stringValue, ip: item["ip"].stringValue, date: sharedDateFormatter.date(from: item["date"].stringValue)))
                }
                
                if items.count < 10 {
                    self.hasMoreLogs = false
                    DispatchQueue.main.async(execute: {
                        self.activityIndicatorView.stopAnimating()
                    })
                }
            }
            
            self.logObjects.sort(by: { $0.date.compare($1.date) == ComparisonResult.orderedDescending })
            self.filteredLogObjects = self.logObjects
            
            DispatchQueue.main.async(execute: { 
                self.tableView.reloadData()
            })
            
            self.operation = false
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    fileprivate func requestNextPage(_ page: Int) {
        if (operation) {
            return
        }
        
        operation = true

        EDDAPIWrapper.sharedInstance.requestFileDownloadLogs([ "page": page as AnyObject ], success: { (json) in
            if let items = json["download_logs"].array {
                if items.count == 10 {
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
            
            self.logObjects.sortInPlace({ $0.date.compare($1.date) == ComparisonResult.orderedDescending })
            self.filteredLogObjects = self.logObjects
            
            self.updateLastDownloadedPage()
            
            DispatchQueue.main.async(execute: { 
                self.tableView.reloadData()
            })
            
            self.operation = false
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    fileprivate func updateLastDownloadedPage() {
        self.lastDownloadedPage = self.lastDownloadedPage + 1;
    }
    
    // MARK: Scroll View Delegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let actualPosition: CGFloat = scrollView.contentOffset.y
        let contentHeight: CGFloat = scrollView.contentSize.height - tableView.frame.size.height;
        
        if actualPosition >= contentHeight && hasMoreLogs && !operation {
            self.requestNextPage(self.lastDownloadedPage)
        }
    }

    
    // MARK: Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredLogObjects.count ?? 0
    }
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: FileDownloadLogsTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "FileDownloadLogCell") as! FileDownloadLogsTableViewCell?
        
        if cell == nil {
            cell = FileDownloadLogsTableViewCell()
        }
    
        cell!.configure(filteredLogObjects[indexPath.row])
        
        cell!.layout()
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let logData = filteredLogObjects[indexPath.row]
        navigationController?.pushViewController(FileDownloadLogsDetailViewController(log: logData), animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: 3D Touch
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRow(at: location) {
            previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
            let logData = filteredLogObjects[indexPath.row]
            return FileDownloadLogsDetailViewController(log: logData)
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }

}

extension FileDownloadLogsViewController: InfiniteScrollingTableView {
    
    func setupInfiniteScrollView() {
        let bounds = UIScreen.main.bounds
        let width = bounds.size.width
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 44))
        footerView.backgroundColor = .clear
        
        activityIndicatorView.startAnimating()
        
        footerView.addSubview(activityIndicatorView)
        
        tableView.tableFooterView = footerView
    }
    
}
