//
//  ManageSitesViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 25/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

class ManageSitesViewController: SiteTableViewController {

    private var sites: [Site]?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        sites = Site.fetchAll(inContext: AppDelegate.sharedInstance.managedObjectContext)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.scrollEnabled = true
        tableView.bounces = true
        tableView.showsVerticalScrollIndicator = true
        tableView.userInteractionEnabled = true
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.editing = true
        
        title = NSLocalizedString("Manage Sites", comment: "")
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(NSLocalizedString("Manage Sites", comment: "Manage Sites title"))
        navigationItem.titleView = titleLabel
    }
    
    func addButtonPressed() {
        let newSiteViewController = NewSiteViewController()
        newSiteViewController.managedObjectContext = AppDelegate.sharedInstance.managedObjectContext
        newSiteViewController.view.backgroundColor = .clearColor()
        newSiteViewController.modalPresentationStyle = .OverFullScreen
        newSiteViewController.modalPresentationCapturesStatusBarAppearance = true
        presentViewController(newSiteViewController, animated: true, completion: nil)
    }
    
    // MARK: Table View Delegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sites?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: Table View Data Source
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ManageSiteCell")
        
        if (cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "ManageSiteCell")
        }
        
        let site = sites![indexPath.row] as Site
        
        cell?.textLabel?.text = site.name!
        
        return cell!
    }

}
