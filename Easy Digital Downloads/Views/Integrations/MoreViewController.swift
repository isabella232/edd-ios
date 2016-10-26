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
        case Misc
    }
    
    private enum Item {
        case SiteInformation
        case ManageSites
        case ProductSearch
        case Commissions
        case StoreCommissions
        case Discounts
        case FileDownloadLogs
        case Reviews
        case Subscriptions
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
        
        title = NSLocalizedString("More", comment: "More title")
        tableView.scrollEnabled = true
        tableView.bounces = true
        tableView.showsVerticalScrollIndicator = true
        tableView.userInteractionEnabled = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = estimatedHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(NSLocalizedString("More", comment: "More title"))
        navigationItem.titleView = titleLabel
        
        sections = [
            Section(type: .General, items: [.SiteInformation, .ManageSites, .ProductSearch]),
        ]
        
        if Site.activeSite().hasCommissions == true {
            sections.append(Section(type: .Commissions, items: [.Commissions, .StoreCommissions]))
        }
        
        if Site.activeSite().hasReviews == true && Site.activeSite().hasRecurring == true {
            sections.append(Section(type: .Misc, items: [.Subscriptions, .FileDownloadLogs, .Discounts, .Reviews]))
        } else if (Site.activeSite().hasReviews == true) {
            sections.append(Section(type: .Misc, items: [.FileDownloadLogs, .Discounts, .Reviews]))
        } else if (Site.activeSite().hasRecurring == true) {
            sections.append(Section(type: .Misc, items: [.Subscriptions, .FileDownloadLogs, .Discounts]))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.leftBarButtonItem = true
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
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
            case .Misc:
                return NSLocalizedString("Misc", comment: "")
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch sections[indexPath.section].items[indexPath.row] {
            case .SiteInformation:
                self.navigationController?.pushViewController(SiteInformationViewController(site: site!), animated: true)
            case .ManageSites:
                self.navigationController?.pushViewController(ManageSitesViewController(), animated: true)
            case .ProductSearch:
                self.navigationController?.pushViewController(SearchViewController(site: site!), animated: true)
            case .FileDownloadLogs:
                self.navigationController?.pushViewController(FileDownloadLogsViewController(site: self.site!), animated: true)
            case .Commissions:
                self.navigationController?.pushViewController(CommissionsViewController(site: site!), animated: true)
            case .StoreCommissions:
                self.navigationController?.pushViewController(StoreCommissionsViewController(site: site!), animated: true)
            case .Discounts:
                self.navigationController?.pushViewController(DiscountsViewController(site: site!), animated: true)
            case .Reviews:
                self.navigationController?.pushViewController(ReviewsViewController(site: site!), animated: true)
            case .Subscriptions:
                self.navigationController?.pushViewController(SubscriptionsViewController(site: site!), animated: true)
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
            case .ProductSearch:
                cell?.textLabel?.text = NSLocalizedString("Product Search", comment: "")
            case .FileDownloadLogs:
                cell?.textLabel?.text = NSLocalizedString("File Download Logs", comment: "")
            case .Commissions:
                cell?.textLabel?.text = NSLocalizedString("Commissions", comment: "")
            case .StoreCommissions:
                cell?.textLabel?.text = NSLocalizedString("Store Commissions", comment: "")
            case .Reviews:
                cell?.textLabel?.text = NSLocalizedString("Reviews", comment: "")
            case .Subscriptions:
                cell?.textLabel?.text = NSLocalizedString("Subscriptions", comment: "")
            case .Discounts:
                cell?.textLabel?.text = NSLocalizedString("Discounts", comment: "")
        }
        
        return cell!
    }
    
}