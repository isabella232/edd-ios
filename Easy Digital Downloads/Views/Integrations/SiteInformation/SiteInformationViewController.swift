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
        
        self.site = Site.activeSite()
        self.managedObjectContext = AppDelegate.sharedInstance.managedObjectContext
        
        title = NSLocalizedString("Site Information", comment: "Site Information title")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 85.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(NSLocalizedString("Site Information", comment: "Site Information title"))
        navigationItem.titleView = titleLabel
        
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
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(SiteInformationViewController.saveButtonPressed))
        navigationItem.rightBarButtonItem = saveButton
    }
    
    func saveButtonPressed() {
        let uiBusy = UIActivityIndicatorView(activityIndicatorStyle: .White)
        uiBusy.hidesWhenStopped = true
        uiBusy.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: uiBusy)
        
        let site = Site.fetchRecordForActiveSite(inContext: managedObjectContext)
        
        let siteNameIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        let siteNameCell: SiteInformationTableViewCell = tableView.cellForRowAtIndexPath(siteNameIndexPath) as! SiteInformationTableViewCell
        
        let siteURLIndexPath = NSIndexPath(forRow: 1, inSection: 0)
        let siteURLCell: SiteInformationTableViewCell = tableView.cellForRowAtIndexPath(siteURLIndexPath) as! SiteInformationTableViewCell
        
        let apiKeyIndexPath = NSIndexPath(forRow: 0, inSection: 1)
        let apiKeyCell: SiteInformationTableViewCell = tableView.cellForRowAtIndexPath(apiKeyIndexPath) as! SiteInformationTableViewCell
        
        let tokenIndexPath = NSIndexPath(forRow: 1, inSection: 1)
        let tokenCell: SiteInformationTableViewCell = tableView.cellForRowAtIndexPath(tokenIndexPath) as! SiteInformationTableViewCell
        
        site.setValue(siteNameCell.textFieldText(), forKey: "name")
        site.setValue(siteURLCell.textFieldText(), forKey: "url")
        
        site.key = apiKeyCell.textFieldText()
        site.token = tokenCell.textFieldText()

        do {
            try managedObjectContext.save()
            self.site = site
            tableView.reloadData()
            
            let saveButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(SiteInformationViewController.saveButtonPressed))
            navigationItem.rightBarButtonItem = saveButton
        } catch {
            print("Unable to save context")
        }
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
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view: UIView = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 40))
        view.backgroundColor = .EDDGreyColor()
        view.userInteractionEnabled = false
        view.tag = section
        
        let label = UILabel(frame: CGRectMake(15, 25, tableView.bounds.size.width - 10, 20))
        label.text = self.tableView(tableView, titleForHeaderInSection: section)?.uppercaseString
        label.textColor = .EDDBlackColor()
        label.font = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
        label.textAlignment = .Left
        
        view.addSubview(label)
        
        return view
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    // MARK: Table View Data Source
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: SiteInformationTableViewCell? = tableView.dequeueReusableCellWithIdentifier("SiteInformationCell") as! SiteInformationTableViewCell?
        
        if cell == nil {
            cell = SiteInformationTableViewCell()
        }
        
        switch sections[indexPath.section].items[indexPath.row] {
            case .SiteName:
                cell!.configure("Site Name", text: site!.name!)
            case .SiteURL:
                cell!.configure("Site URL", text: site!.url!)
            case .APIKey:
                cell!.configure("API Key", text: site!.key)
            case .Token:
                cell!.configure("Token", text: site!.token)
        }
        
        cell!.layout()
        
        return cell!
    }
    
}
