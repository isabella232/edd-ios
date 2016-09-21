//
//  MoreViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 18/08/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData

class MoreViewController: SiteTableViewController, ManagedObjectContextSettable {
    
    private enum SectionType {
        case General
        case Commissions
        case Logs
        case Integrations
    }
    
    private enum Item {
        case SiteInformation
        case ManageSites
        case Commissions
        case StoreCommissions
        case FileDownloadLogs
        case Reviews
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
        
        title = NSLocalizedString("More", comment: "More View Controller title")
        tableView.scrollEnabled = true
        tableView.bounces = true
        tableView.showsVerticalScrollIndicator = true
        tableView.userInteractionEnabled = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = estimatedHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        
        sections = [
            Section(type: .General, items: [.SiteInformation, .ManageSites]),
            Section(type: .Commissions, items: [.Commissions, .StoreCommissions]),
            Section(type: .Logs, items: [.FileDownloadLogs]),
            Section(type: .Integrations, items: [.Reviews])
        ]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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

            case .Commissions:
                return NSLocalizedString("Commissions", comment: "")

            case .Logs:
                return NSLocalizedString("Logs", comment: "")

            case .Integrations:
                return NSLocalizedString("Integrations", comment: "")
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch sections[indexPath.section].items[indexPath.row] {
            case .SiteInformation:
                self.navigationController?.pushViewController(SiteInformationViewController(site: site!), animated: true)
            case .ManageSites:
                self.navigationController?.pushViewController(SiteInformationViewController(site: site!), animated: true)
            case .FileDownloadLogs:
                self.navigationController?.pushViewController(FileDownloadLogsController(site: self.site!), animated: true)
            case .Commissions:
                self.navigationController?.pushViewController(SiteInformationViewController(site: site!), animated: true)
            case .StoreCommissions:
                self.navigationController?.pushViewController(SiteInformationViewController(site: site!), animated: true)
            case .Reviews:
                self.navigationController?.pushViewController(SiteInformationViewController(site: site!), animated: true)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

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
        var cell = tableView.dequeueReusableCellWithIdentifier("MoreCell")
        
        if (cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "MoreCell")
        }
        
        cell?.accessoryType = .DisclosureIndicator
        
        switch sections[indexPath.section].items[indexPath.row] {
            case .SiteInformation:
                cell?.textLabel?.text = NSLocalizedString("Site Information", comment: "")
            case .ManageSites:
                cell?.textLabel?.text = NSLocalizedString("Manage Sites", comment: "")
            case .FileDownloadLogs:
                cell?.textLabel?.text = NSLocalizedString("File Download Logs", comment: "")
            case .Commissions:
                cell?.textLabel?.text = NSLocalizedString("Commissions", comment: "")
            case .StoreCommissions:
                cell?.textLabel?.text = NSLocalizedString("Store Commissions", comment: "")
            case .Reviews:
                cell?.textLabel?.text = NSLocalizedString("Reviews", comment: "")
        }
        
        return cell!
    }
    
}
