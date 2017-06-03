//
//  ManageSitesViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 25/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import Alamofire

class ManageSitesViewController: SiteTableViewController {

    fileprivate var sites: [Site]?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sites = Site.fetchAll(inContext: AppDelegate.sharedInstance.managedObjectContext)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.isScrollEnabled = true
        tableView.bounces = true
        tableView.showsVerticalScrollIndicator = true
        tableView.isUserInteractionEnabled = true
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isEditing = true
        
        title = NSLocalizedString("Manage Sites", comment: "")
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(NSLocalizedString("Manage Sites", comment: "Manage Sites title"))
        navigationItem.titleView = titleLabel
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ManageSitesViewController.addButtonPressed))
        navigationItem.rightBarButtonItem = addButton
    }
    
    func addButtonPressed() {
        let newSiteViewController = NewSiteViewController()
        newSiteViewController.managedObjectContext = AppDelegate.sharedInstance.managedObjectContext
        newSiteViewController.view.backgroundColor = .clear
        newSiteViewController.modalPresentationStyle = .overFullScreen
        newSiteViewController.modalPresentationCapturesStatusBarAppearance = true
        present(newSiteViewController, animated: true, completion: nil)
    }
    
    // MARK: Table View Delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sites?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Table View Data Source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ManageSiteCell")
        
        if (cell == nil) {
            cell = UITableViewCell(style: .default, reuseIdentifier: "ManageSiteCell")
        }
        
        let site = sites![indexPath.row] as Site
        
        cell?.textLabel?.text = site.name!
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let site = sites![indexPath.row] as Site
            
            let uid = site.uid!
            
            if sites!.count == 1 {
                Site.deleteSite(uid)
                sites!.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                present(LoginViewController(), animated: true, completion: nil)
                return
            }
            
            if Site.activeSite().uid == site.uid && sites!.count > 1 {
                Site.deleteSite(uid)
                sites!.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                let newSite = Site.refreshActiveSite()
                AppDelegate.sharedInstance.switchActiveSite(newSite.uid!)
                UIView.transition(with: self.view.window!, duration: 0.5, options: UIViewAnimationOptions.transitionFlipFromLeft, animations: {
                    self.view.window?.rootViewController = SiteTabBarController(site: newSite)
                    }, completion: nil)
                return
            }
            
            // Delete from Core Data
            Site.deleteSite(site.uid!)
            
            sites!.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}
