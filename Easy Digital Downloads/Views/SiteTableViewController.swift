//
//  SiteTableViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 29/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

class SiteTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let leftNavigationItemImage = UIImage(named: "NavigationBar-SwitchSite")
        let leftNavigationItemButton = HighlightButton(type: .Custom)
        leftNavigationItemButton.tintColor = .whiteColor()
        leftNavigationItemButton.setImage(leftNavigationItemImage, forState: .Normal)
        leftNavigationItemButton.sizeToFit()
        
        let leftNavigationBarButton = UIBarButtonItem(customView: leftNavigationItemButton)
        leftNavigationBarButton.accessibilityIdentifier = "Switch Site"
        navigationItem.leftBarButtonItems = [leftNavigationBarButton]
    }
    
    override func viewWillAppear(animated: Bool) {
        view.backgroundColor = .EDDGreyColor()
        
        animateTable()
    }
    
    func animateTable() {
        tableView.reloadData()
        
        let navigationBar = navigationController?.navigationBar
        navigationBar?.transform = CGAffineTransformMakeTranslation(0, -80);
        navigationBar?.layer.opacity = 0.5
        
        let tabBar = tabBarController?.tabBar
        tabBar?.transform = CGAffineTransformMakeTranslation(0, 80);
        tabBar?.layer.opacity = 0.5
        
        let cells = tableView.visibleCells
        let tableHeight: CGFloat = tableView.bounds.size.height
        
        UIView.animateWithDuration(0.5) {
            navigationBar?.transform = CGAffineTransformMakeTranslation(0, 0)
            navigationBar?.layer.opacity = 1.0
            
            tabBar?.transform = CGAffineTransformMakeTranslation(0, 0)
            tabBar?.layer.opacity = 1.0
        }
        
        for i in cells {
            let cell: UITableViewCell = i as UITableViewCell
            cell.transform = CGAffineTransformMakeTranslation(0, tableHeight)
        }
        
        var index = 0
        
        for a in cells {
            let cell: UITableViewCell = a as UITableViewCell
            UIView.animateWithDuration(1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                cell.transform = CGAffineTransformMakeTranslation(0, 0);
                }, completion: nil)
            
            index += 1
        }
    }

}