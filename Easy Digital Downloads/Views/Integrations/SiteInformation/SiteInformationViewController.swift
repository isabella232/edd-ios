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
    
    fileprivate enum SectionType {
        case general
        case authentication
        case permissions
        case misc
    }
    
    fileprivate enum Item {
        case siteName
        case siteURL
        case apiKey
        case token
        case commissions
    }
    
    fileprivate struct Section {
        var type: SectionType
        var items: [Item]
    }
    
    fileprivate var sections = [Section]()

    var managedObjectContext: NSManagedObjectContext!
    
    let sharedDefaults: UserDefaults = UserDefaults(suiteName: "group.easydigitaldownloads.EDDSalesTracker")!
    
    var site: Site?
    
    init(site: Site) {
        super.init(style: .plain)
        
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
            Section(type: .general, items: [.siteName, .siteURL]),
            Section(type: .authentication, items: [.apiKey, .token])
        ]
        
        if (Site.activeSite().hasCommissions?.boolValue == true) {
            sections.append(Section(type: .misc, items: [.commissions]))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(SiteInformationViewController.saveButtonPressed))
        navigationItem.rightBarButtonItem = saveButton
    }
    
    func saveButtonPressed() {
        let uiBusy = UIActivityIndicatorView(activityIndicatorStyle: .white)
        uiBusy.hidesWhenStopped = true
        uiBusy.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: uiBusy)
        
        let site = Site.fetchRecordForActiveSite(inContext: managedObjectContext)
        
        let siteNameIndexPath = IndexPath(row: 0, section: 0)
        let siteNameCell: SiteInformationTableViewCell = tableView.cellForRow(at: siteNameIndexPath) as! SiteInformationTableViewCell
        
        let siteURLIndexPath = IndexPath(row: 1, section: 0)
        let siteURLCell: SiteInformationTableViewCell = tableView.cellForRow(at: siteURLIndexPath) as! SiteInformationTableViewCell
        
        let apiKeyIndexPath = IndexPath(row: 0, section: 1)
        let apiKeyCell: SiteInformationTableViewCell = tableView.cellForRow(at: apiKeyIndexPath) as! SiteInformationTableViewCell
        
        let tokenIndexPath = IndexPath(row: 1, section: 1)
        let tokenCell: SiteInformationTableViewCell = tableView.cellForRow(at: tokenIndexPath) as! SiteInformationTableViewCell
        
        site.setValue(siteNameCell.textFieldText(), forKey: "name")
        site.setValue(siteURLCell.textFieldText(), forKey: "url")
        
        site.key = apiKeyCell.textFieldText()
        site.token = tokenCell.textFieldText()

        do {
            try managedObjectContext.save()
            self.site = site
            tableView.reloadData()
            
            let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(SiteInformationViewController.saveButtonPressed))
            navigationItem.rightBarButtonItem = saveButton
        } catch {
            print("Unable to save context")
        }
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
            case .authentication:
                return NSLocalizedString("Authentication", comment: "")
            case .permissions:
                return NSLocalizedString("Permissions", comment: "")
            case .misc:
                return NSLocalizedString("Dashboard Layout", comment: "")
        }
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
        if sections[indexPath.section].items[indexPath.row] == .commissions {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "commissionsToggleCell")
            let switchView = UISwitch(frame: CGRect.zero)
            switchView.addTarget(self, action: #selector(SiteInformationViewController.toggleCommissionsDisplay(_:)), for: .touchUpInside)
            cell.textLabel!.text = NSLocalizedString("Disply Commissions on Dashboard?", comment: "")
            cell.accessoryView = switchView
            
            if sharedDefaults.bool(forKey: Site.activeSite().uid! + "-DisplayCommissions") == true {
                switchView.setOn(true, animated: true)
            }
            
            return cell
        }
        
        var cell: SiteInformationTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "SiteInformationCell") as! SiteInformationTableViewCell?
        
        if cell == nil {
            cell = SiteInformationTableViewCell()
        }
        
        switch sections[indexPath.section].items[indexPath.row] {
            case .siteName:
                cell!.configure("Site Name", text: site!.name!)
            case .siteURL:
                cell!.configure("Site URL", text: site!.url!)
            case .apiKey:
                cell!.configure("API Key", text: site!.key)
            case .token:
                cell!.configure("Token", text: site!.token)
            default:
                cell!.configure("", text: "")
        }
        
        cell!.layout()
        
        return cell!
    }
    
    func toggleCommissionsDisplay(_ sender: UISwitch) {
        if sender.isOn {
            sharedDefaults.set(true, forKey: Site.activeSite().uid! + "-DisplayCommissions")
        } else {
            sharedDefaults.set(false, forKey: Site.activeSite().uid! + "-DisplayCommissions")
        }

        sharedDefaults.synchronize()
    }
    
}
