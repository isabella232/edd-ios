//
//  SwitchSiteViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 17/07/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

class SwitchSiteViewController: UITableViewController {

    fileprivate var sites: [Site]?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sites = Site.fetchAll(inContext: AppDelegate.sharedInstance.managedObjectContext)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurEffect = UIBlurEffect(style: .dark)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.frame = tableView.frame
        
        title = NSLocalizedString("Switch Site", comment: "")
        
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barStyle = .blackTranslucent
        
        tableView.isScrollEnabled = true
        tableView.bounces = true
        tableView.showsVerticalScrollIndicator = true
        tableView.isUserInteractionEnabled = true
        tableView.backgroundColor = .clear
        tableView.separatorColor = UIColor.separatorColor()
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 85.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(SwitchSiteTableViewCell.self, forCellReuseIdentifier: "SwitchSiteTableViewCell")
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(SwitchSiteViewController.doneButtonPressed))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(SwitchSiteViewController.addButtonPressed))
        navigationItem.rightBarButtonItem = doneButton
        navigationItem.leftBarButtonItem = addButton

        tableView.backgroundView = visualEffectView
    }
    
    func doneButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    func addButtonPressed() {
        let newSiteViewController = NewSiteViewController()
        newSiteViewController.managedObjectContext = AppDelegate.sharedInstance.managedObjectContext
        newSiteViewController.view.backgroundColor = .clear
        newSiteViewController.modalPresentationStyle = .overFullScreen
        newSiteViewController.modalPresentationCapturesStatusBarAppearance = true
        present(newSiteViewController, animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    // MARK: Table View Delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sites?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let site = sites![indexPath.row] as Site
        
        tableView.deselectRow(at: indexPath, animated: true)

        AppDelegate.sharedInstance.switchActiveSite(site.uid!)

        UIView.transition(with: self.view.window!, duration: 0.5, options: UIViewAnimationOptions.transitionFlipFromLeft, animations: {
            self.view.window?.rootViewController = SiteTabBarController(site: site)
            }, completion: nil)
    }
    
    // MARK: Table View Data Source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: SwitchSiteTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "SwitchSiteTableViewCell") as! SwitchSiteTableViewCell?
        
        if (cell == nil) {
            cell = SwitchSiteTableViewCell()
        }
        
        let site = sites![indexPath.row] as Site
        
        cell?.configure(site)
        
        return cell!
    }
    
}
