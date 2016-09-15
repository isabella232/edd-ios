//
//  SwitchSiteViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 17/07/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

class SwitchSiteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var tableView: UITableView!
    private var navigationBar: UINavigationBar!
    private var sites: [Site]?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        sites = Site.fetchAll(inContext: AppDelegate.sharedInstance.managedObjectContext)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurEffect = UIBlurEffect(style: .Dark)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.frame = view.bounds
        
        navigationBar = UINavigationBar(frame: CGRectMake(0, 0, view.frame.width, 64))
        navigationBar.translucent = true
        navigationBar.barStyle = .BlackTranslucent
        
        tableView = UITableView(frame: CGRectMake(0, navigationBar.frame.height, view.frame.width, view.frame.height - navigationBar.frame.height) ,style: .Plain);
        tableView.scrollEnabled = true
        tableView.bounces = true
        tableView.showsVerticalScrollIndicator = true
        tableView.userInteractionEnabled = true
        tableView.backgroundColor = .clearColor()
        tableView.separatorColor = UIColor.separatorColor()
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        
        let navigationItem = UINavigationItem(title: NSLocalizedString("Switch Site", comment: ""))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(SwitchSiteViewController.doneButtonPressed))
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(SwitchSiteViewController.addButtonPressed))
        navigationItem.rightBarButtonItem = doneButton
        navigationItem.leftBarButtonItem = addButton
        navigationBar.items = [navigationItem]
        
        title = NSLocalizedString("Edit Dashboard", comment: "")
        
        view.addSubview(visualEffectView)
        view.addSubview(tableView)
        view.addSubview(navigationBar)
    }
    
    func doneButtonPressed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addButtonPressed() {
        let newSiteViewController = NewSiteViewController()
        newSiteViewController.managedObjectContext = AppDelegate.sharedInstance.managedObjectContext
        newSiteViewController.view.backgroundColor = .clearColor()
        newSiteViewController.modalPresentationStyle = .OverFullScreen
        newSiteViewController.modalPresentationCapturesStatusBarAppearance = true
        presentViewController(newSiteViewController, animated: true, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    // MARK: Table View Delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sites?.count ?? 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let site = sites![indexPath.row] as Site
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        AppDelegate.sharedInstance.switchActiveSite(site.uid!)

        UIView.transitionWithView(self.view.window!, duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromLeft, animations: {
            self.view.window?.rootViewController = SiteTabBarController(site: site)
            }, completion: nil)
    }
    
    // MARK: Table View Data Source
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("SwitchSiteCell")
        
        if (cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "SwitchSiteCell")
        }
        
        cell?.backgroundColor = UIColor.clearColor()
        cell?.textLabel?.textColor = UIColor.whiteColor()
        
        let site = sites![indexPath.row] as Site
        
        cell?.textLabel?.text = site.name!
        
        return cell!
    }
    
}
