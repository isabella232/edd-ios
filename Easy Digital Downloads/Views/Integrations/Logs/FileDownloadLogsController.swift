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
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        networkOperations()
    }
    
    // MARK: Network Operations
    
    private func networkOperations() {
        logs = [JSON]()

        EDDAPIWrapper.sharedInstance.requestFileDownloadLogs([:], success: { (json) in
            if let items = json["download_logs"].array {
                self.logs = items
                self.tableView.reloadData()
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
        return (self.logs?.count)!
    }
    
    // MARK: Table View Delegate
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("FileDownloadLogCell")

        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "FileDownloadLogCell")
        }
        
        let logData = self.logs![indexPath.row].dictionaryObject!
        
        cell?.textLabel?.text = logData["product_name"] as? String
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
}
