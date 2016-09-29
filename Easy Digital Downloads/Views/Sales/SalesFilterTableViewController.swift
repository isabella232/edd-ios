//
//  SalesFilterTableViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 29/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

class SalesFilterTableViewController: UIViewController {

    private var tableView: UITableView!
    private var navigationBar: UINavigationBar!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar = UINavigationBar(frame: CGRectMake(0, 0, view.frame.width, 64))
        navigationBar.translucent = false
        navigationBar.barStyle = .Black
        
        tableView = UITableView(frame: CGRectMake(0, navigationBar.frame.height, view.frame.width, view.frame.height - navigationBar.frame.height) ,style: .Plain);
        tableView.scrollEnabled = true
        tableView.bounces = true
        tableView.showsVerticalScrollIndicator = true
        tableView.userInteractionEnabled = true
        tableView.backgroundColor = .clearColor()
        tableView.separatorColor = UIColor.separatorColor()
        tableView.tableFooterView = UIView()
//        tableView.dataSource = self
//        tableView.delegate = self
        
        let navigationItem = UINavigationItem(title: NSLocalizedString("Filter Sales", comment: ""))
        let closeButton = UIBarButtonItem(title: NSLocalizedString("Close", comment: ""), style: .Plain, target: self, action: #selector(SalesFilterTableViewController.closeButtonPressed))
        navigationItem.leftBarButtonItem = closeButton
        navigationBar.items = [navigationItem]
        
        title = NSLocalizedString("Filter Sales", comment: "")
        
        view.addSubview(tableView)
        view.addSubview(navigationBar)
    }
    
    func closeButtonPressed() {
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

}
