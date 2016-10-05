//
//  FileDownloadLogsController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 22/08/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON
import Haneke

class FileDownloadLogsController: SiteTableViewController, ManagedObjectContextSettable, UIViewControllerPreviewingDelegate {

    var managedObjectContext: NSManagedObjectContext!
    
    typealias JSON = SwiftyJSON.JSON
    
    var site: Site?
    var logs: [JSON]?
    let sharedCache = Shared.dataCache
    
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
            self.logs = json["download_logs"].array
            
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

            self.logs?.removeAll(keepCapacity: false)
            
            if let items = json["download_logs"].array {
                self.logs = items
                self.requestNextPage(2)
            }
            
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
                    self.logs?.append(item)
                }
            } else {
                self.hasMoreLogs = false
            }
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
        return self.logs?.count ?? 0
    }
    
    // MARK: Table View Delegate
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: FileDownloadLogsTableViewCell? = tableView.dequeueReusableCellWithIdentifier("FileDownloadLogCell") as! FileDownloadLogsTableViewCell?
        
        if cell == nil {
            cell = FileDownloadLogsTableViewCell()
        }
        
        let logData = self.logs![indexPath.row].dictionaryObject!
        
        cell!.configure(logData)
        
        cell!.layout()
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let logData = self.logs![indexPath.row].dictionaryObject!
        navigationController?.pushViewController(FileDownloadLogsDetailViewController(log: logData), animated: true)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: 3D Touch
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRowAtPoint(location) {
            previewingContext.sourceRect = tableView.rectForRowAtIndexPath(indexPath)
            let logData = self.logs![indexPath.row].dictionaryObject!
            return FileDownloadLogsDetailViewController(log: logData)
        }
        return nil
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }

}

extension FileDownloadLogsController: InfiniteScrollingTableView {
    
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
