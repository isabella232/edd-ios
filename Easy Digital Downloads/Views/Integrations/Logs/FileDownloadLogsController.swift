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

class FileDownloadLogsController: SiteTableViewController, ManagedObjectContextSettable {

    var managedObjectContext: NSManagedObjectContext!
    
    var site: Site?
    var logs: [JSON]?
    
    init(site: Site) {
        super.init(style: .Plain)
        
        self.site = site
        self.managedObjectContext = AppDelegate.sharedInstance.managedObjectContext
        
        title = NSLocalizedString("File Download Logs", comment: "File Download Logs title")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 85.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        networkOperations()
    }
    
    // MARK: Network Operations
    
    private func networkOperations() {
        logs = [JSON]()

        EDDAPIWrapper.sharedInstance.requestFileDownloadLogs([:], success: { (json) in
            if let items = json["download_logs"].array {
                self.logs = items
            }
            self.tableView.reloadData()
            }) { (error) in
                fatalError()
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
    
}
