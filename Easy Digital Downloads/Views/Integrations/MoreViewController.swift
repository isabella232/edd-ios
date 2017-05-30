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
    
    fileprivate enum SectionType {
        case general
        case commissions
        case misc
    }
    
    fileprivate enum Item {
        case siteInformation
        case manageSites
        case productSearch
        case commissions
        case storeCommissions
        case discounts
        case fileDownloadLogs
        case reviews
        case subscriptions
    }
    
    fileprivate struct Section {
        var type: SectionType
        var items: [Item]
    }
    
    fileprivate var sections = [Section]()

    var managedObjectContext: NSManagedObjectContext!
    
    var site: Site?
    
    init(site: Site) {
        super.init(style: .plain)
        
        self.site = site
        
        title = NSLocalizedString("More", comment: "More title")
        tableView.isScrollEnabled = true
        tableView.bounces = true
        tableView.showsVerticalScrollIndicator = true
        tableView.isUserInteractionEnabled = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = estimatedHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(NSLocalizedString("More", comment: "More title"))
        navigationItem.titleView = titleLabel
        
        sections = [
            Section(type: .general, items: [.siteInformation, .manageSites, .productSearch]),
        ]
        
        if Site.activeSite().hasCommissions == true {
            sections.append(Section(type: .commissions, items: [.commissions, .storeCommissions]))
        }
        
        if Site.activeSite().hasReviews == true && Site.activeSite().hasRecurring == true {
            sections.append(Section(type: .misc, items: [.subscriptions, .fileDownloadLogs, .discounts, .reviews]))
        } else if (Site.activeSite().hasReviews == true) {
            sections.append(Section(type: .misc, items: [.fileDownloadLogs, .discounts, .reviews]))
        } else if (Site.activeSite().hasRecurring == true) {
            sections.append(Section(type: .misc, items: [.subscriptions, .fileDownloadLogs, .discounts]))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.leftBarButtonItem = true
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Table View Delegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sections[section].type {
            case .general:
                return NSLocalizedString("General", comment: "")
            case .commissions:
                return NSLocalizedString("Commissions", comment: "")
            case .misc:
                return NSLocalizedString("Misc", comment: "")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections[indexPath.section].items[indexPath.row] {
            case .siteInformation:
                self.navigationController?.pushViewController(SiteInformationViewController(site: site!), animated: true)
            case .manageSites:
                self.navigationController?.pushViewController(ManageSitesViewController(), animated: true)
            case .productSearch:
                self.navigationController?.pushViewController(SearchViewController(site: site!), animated: true)
            case .fileDownloadLogs:
                self.navigationController?.pushViewController(FileDownloadLogsViewController(site: self.site!), animated: true)
            case .commissions:
                self.navigationController?.pushViewController(CommissionsViewController(site: site!), animated: true)
            case .storeCommissions:
                self.navigationController?.pushViewController(StoreCommissionsViewController(site: site!), animated: true)
            case .discounts:
                self.navigationController?.pushViewController(DiscountsViewController(site: site!), animated: true)
            case .reviews:
                self.navigationController?.pushViewController(ReviewsViewController(site: site!), animated: true)
            case .subscriptions:
                self.navigationController?.pushViewController(SubscriptionsViewController(site: site!), animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view: UIView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 40))
        view.backgroundColor = .EDDGreyColor()
        view.isUserInteractionEnabled = false
        view.tag = section
        
        let label = UILabel(frame: CGRect(x: 15, y: 25, width: tableView.bounds.size.width - 10, height: 20))
        label.text = self.tableView(tableView, titleForHeaderInSection: section)?.uppercased()
        label.textColor = .EDDBlackColor()
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight)
        label.textAlignment = .left
        
        view.addSubview(label)
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    // MARK: Table View Data Source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MoreCell")
        
        if (cell == nil) {
            cell = UITableViewCell(style: .default, reuseIdentifier: "MoreCell")
        }
        
        cell?.accessoryType = .disclosureIndicator
        
        switch sections[indexPath.section].items[indexPath.row] {
            case .siteInformation:
                cell?.textLabel?.text = NSLocalizedString("Site Information", comment: "")
            case .manageSites:
                cell?.textLabel?.text = NSLocalizedString("Manage Sites", comment: "")
            case .productSearch:
                cell?.textLabel?.text = NSLocalizedString("Product Search", comment: "")
            case .fileDownloadLogs:
                cell?.textLabel?.text = NSLocalizedString("File Download Logs", comment: "")
            case .commissions:
                cell?.textLabel?.text = NSLocalizedString("Commissions", comment: "")
            case .storeCommissions:
                cell?.textLabel?.text = NSLocalizedString("Store Commissions", comment: "")
            case .reviews:
                cell?.textLabel?.text = NSLocalizedString("Reviews", comment: "")
            case .subscriptions:
                cell?.textLabel?.text = NSLocalizedString("Subscriptions", comment: "")
            case .discounts:
                cell?.textLabel?.text = NSLocalizedString("Discounts", comment: "")
        }
        
        return cell!
    }
    
}
