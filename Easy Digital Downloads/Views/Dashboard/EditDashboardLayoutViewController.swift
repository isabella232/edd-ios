//
//  EditDashboardLayoutViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 04/07/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

class EditDashboardLayoutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var tableView: UITableView!
    private var navigationBar: UINavigationBar!
    private var site: Site!
    private var dashboardOrder: [Int]!
    private var dashboardCellLabels = ["Sales", "Earnings", "Commissions", "Store Commissions", "Revews"]
    
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
        tableView.dataSource = self
        tableView.delegate = self
        
        let navigationItem = UINavigationItem(title: NSLocalizedString("Edit Dashboard Layout", comment: ""))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(EditDashboardLayoutViewController.doneButtonPressed))
        navigationItem.rightBarButtonItem = doneButton
        navigationBar.items = [navigationItem]
        
        title = NSLocalizedString("Edit Dashboard", comment: "")
        
        view.addSubview(visualEffectView)
        view.addSubview(tableView)
        view.addSubview(navigationBar)
        
        dashboardOrder = Site.getDashboardOrderForActiveSite()
        
        for elem in dashboardOrder {
            if elem == DashboardCell.Sales.rawValue {
                dashboardCellLabels[elem] = NSLocalizedString("Sales", comment: "")
            }
            
            if elem == DashboardCell.Earnings.rawValue {
                dashboardCellLabels[elem] = NSLocalizedString("Earnings", comment: "")
            }
            
            if elem == DashboardCell.Commissions.rawValue {
                dashboardCellLabels[elem] = NSLocalizedString("Commissions", comment: "")
            }
            
            if elem == DashboardCell.StoreCommissions.rawValue {
                dashboardCellLabels[elem] = NSLocalizedString("Store Commissions", comment: "")
            }
        }

    }
    
    init(site: Site) {
        self.site = site
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
    
    // MARK: UITableViewDelegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dashboardOrder.count
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        let itemToMove = dashboardOrder[fromIndexPath.row]
        let labelToMove = dashboardCellLabels[fromIndexPath.row]
        dashboardOrder.removeAtIndex(fromIndexPath.row)
        dashboardCellLabels.removeAtIndex(fromIndexPath.row)
        dashboardOrder.insert(itemToMove, atIndex: toIndexPath.row)
        dashboardCellLabels.insert(labelToMove, atIndex: toIndexPath.row)
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    
    // MARK: UITableViewDataSource

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("DashboardLayoutCell")
        
        if (cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "DashboardLayoutCell")
        }
        
        cell?.backgroundColor = UIColor.clearColor()
        cell?.textLabel?.textColor = UIColor.whiteColor()
        
        cell?.textLabel?.text = dashboardCellLabels[indexPath.row]
        
        return cell!
    }
    
}
