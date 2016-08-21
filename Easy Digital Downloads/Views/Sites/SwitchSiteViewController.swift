//
//  SwitchSiteViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 17/07/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

class SwitchSiteViewController: UIViewController {

    private var tableView: UITableView!
    private var navigationBar: UINavigationBar!
    
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
        tableView.editing = true
        tableView.tableFooterView = UIView()
//        tableView.dataSource = self
//        tableView.delegate = self
        
        let navigationItem = UINavigationItem(title: NSLocalizedString("Switch Site", comment: ""))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(EditDashboardLayoutViewController.doneButtonPressed))
        navigationItem.rightBarButtonItem = doneButton
        navigationBar.items = [navigationItem]
        
        title = NSLocalizedString("Edit Dashboard", comment: "")
        
        view.addSubview(visualEffectView)
        view.addSubview(tableView)
        view.addSubview(navigationBar)
    }
    
    func doneButtonPressed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
}
