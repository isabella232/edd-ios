//
//  EditDashboardLayoutViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 04/07/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

class EditDashboardLayoutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    fileprivate var tableView: UITableView!
    fileprivate var navigationBar: UINavigationBar!
    fileprivate var site: Site!
    fileprivate var dashboardOrder: [Int]!
    fileprivate var dashboardCellLabels = ["Sales", "Earnings", "Commissions", "Store Commissions", "Revews"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurEffect = UIBlurEffect(style: .dark)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.frame = view.bounds
        
        navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 64))
        navigationBar.isTranslucent = true
        navigationBar.barStyle = .blackTranslucent
        
        tableView = UITableView(frame: CGRect(x: 0, y: navigationBar.frame.height, width: view.frame.width, height: view.frame.height - navigationBar.frame.height) ,style: .plain);
        tableView.isScrollEnabled = true
        tableView.bounces = true
        tableView.showsVerticalScrollIndicator = true
        tableView.isUserInteractionEnabled = true
        tableView.backgroundColor = .clear
        tableView.separatorColor = UIColor.separatorColor()
        tableView.isEditing = true
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        
        let navigationItem = UINavigationItem(title: NSLocalizedString("Edit Dashboard Layout", comment: ""))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(EditDashboardLayoutViewController.doneButtonPressed))
        navigationItem.rightBarButtonItem = doneButton
        navigationBar.items = [navigationItem]
        
        title = NSLocalizedString("Edit Dashboard", comment: "")
        
        view.addSubview(visualEffectView)
        view.addSubview(tableView)
        view.addSubview(navigationBar)
        
        dashboardOrder = Site.getDashboardOrderForActiveSite()
        
        for elem in dashboardOrder {
            if elem == DashboardCell.sales.rawValue {
                dashboardCellLabels[elem] = NSLocalizedString("Sales", comment: "")
            }
            
            if elem == DashboardCell.earnings.rawValue {
                dashboardCellLabels[elem] = NSLocalizedString("Earnings", comment: "")
            }
            
            if elem == DashboardCell.commissions.rawValue {
                dashboardCellLabels[elem] = NSLocalizedString("Commissions", comment: "")
            }
            
            if elem == DashboardCell.storeCommissions.rawValue {
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
        dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    // MARK: UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dashboardOrder.count
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        let itemToMove = dashboardOrder[fromIndexPath.row]
        let labelToMove = dashboardCellLabels[fromIndexPath.row]
        dashboardOrder.remove(at: fromIndexPath.row)
        dashboardCellLabels.remove(at: fromIndexPath.row)
        dashboardOrder.insert(itemToMove, at: toIndexPath.row)
        dashboardCellLabels.insert(labelToMove, at: toIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    
    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "DashboardLayoutCell")
        
        if (cell == nil) {
            cell = UITableViewCell(style: .default, reuseIdentifier: "DashboardLayoutCell")
        }
        
        cell?.backgroundColor = UIColor.clear
        cell?.textLabel?.textColor = UIColor.white
        
        cell?.textLabel?.text = dashboardCellLabels[indexPath.row]
        
        return cell!
    }
    
}
