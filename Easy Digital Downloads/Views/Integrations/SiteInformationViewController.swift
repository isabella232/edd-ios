//
//  SiteInformationViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 22/08/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData

class SiteInformationViewController: SiteTableViewController, ManagedObjectContextSettable {
    
    private enum SectionType {
        case General
        case Authentication
        case Permissions
    }
    
    private enum Item {
        case SiteName
        case SiteURL
        case APIKey
        case Token
    }
    
    private struct Section {
        var type: SectionType
        var items: [Item]
    }
    
    private var sections = [Section]()

    var managedObjectContext: NSManagedObjectContext!
    
    var site: Site?
    
    init(site: Site) {
        super.init(style: .Plain)
        
        self.site = site
        self.managedObjectContext = AppDelegate.sharedInstance.managedObjectContext
        
        title = NSLocalizedString("Site Information", comment: "Site Information title")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 85.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        sections = [
            Section(type: .General, items: [.SiteName, .SiteURL]),
            Section(type: .Authentication, items: [.APIKey, .Token])
        ]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Table View Delegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sections[section].type {
            case .General:
                return NSLocalizedString("General", comment: "")
            case .Authentication:
                return NSLocalizedString("Authentication", comment: "")
            case .Permissions:
                return NSLocalizedString("Permissions", comment: "")
        }
    }
    
    // MARK: Table View Data Source
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("SiteInformationCell")
        
        if (cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "SiteInformationCell")
        }
        
        switch sections[indexPath.section].items[indexPath.row] {
            case .SiteName:
                cell?.textLabel?.text = NSLocalizedString("Site Name", comment: "")
            case .SiteURL:
                cell?.textLabel?.text = NSLocalizedString("Site URL", comment: "")
            case .APIKey:
                cell?.textLabel?.text = NSLocalizedString("API Key", comment: "")
            case .Token:
                cell?.textLabel?.text = NSLocalizedString("Token", comment: "")
        }
        
        return cell!
    }
    
}
