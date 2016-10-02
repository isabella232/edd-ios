//
//  SiteTableViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 29/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

class SiteTableViewController: UITableViewController {
    
    var refreshLoadingView : UIView!
    var refreshColorView : UIView!
    var compass_background : UIImageView!
    var eddImageView : UIImageView!
    var compass_spinner : UIImageView!
    
    var isRefreshIconsOverlap = false
    var isRefreshAnimating = false
    
    var leftBarButtonItem : Bool? {
        didSet {
            setupSwitchSiteIcon()
        }
    }
    
    var hasNoInternetConnection : Bool? {
        didSet {
            for view in self.view.subviews {
                if view.tag == 1 {
                    return
                }
            }
            
            displayNoNetworkConnectionView()
        }
    }
    
    var topLayoutAnchor: CGFloat = 0.0
    
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        
        let bounds = UIScreen.mainScreen().bounds
        let width = bounds.size.width
        
        activityIndicator.center = CGPointMake(width / 2, 22)
        activityIndicator.color = .EDDBlueColor()
        
        return activityIndicator
    }()
    
    lazy var noInternetConnection: UIView = {
        let bounds: CGRect = UIScreen.mainScreen().bounds
        let width: CGFloat = bounds.width
        let height: CGFloat = 30.0
        
        let offlineView = UIView(frame: CGRectMake(0, 0, width, height))
        offlineView.backgroundColor = .errorColor()
        offlineView.transform = CGAffineTransformMakeTranslation(0, -80)
        offlineView.tag == 1
        
        let offlineLabel = UILabel(frame: CGRectMake(0, 0, width, height))
        offlineLabel.text = NSLocalizedString("No network connection", comment: "")
        offlineLabel.textColor = .whiteColor()
        offlineLabel.textAlignment = .Center
        
        offlineView.addSubview(offlineLabel)

        return offlineView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        view.backgroundColor = .EDDGreyColor()
    }
    
    private func setupSwitchSiteIcon() {
        let leftNavigationItemImage = UIImage(named: "NavigationBar-SwitchSite")
        let leftNavigationItemButton = HighlightButton(type: .Custom)
        leftNavigationItemButton.tintColor = .whiteColor()
        leftNavigationItemButton.setImage(leftNavigationItemImage, forState: .Normal)
        leftNavigationItemButton.addTarget(self, action: #selector(SiteTableViewController.editSwitchSiteButtonPressed), forControlEvents: .TouchUpInside)
        leftNavigationItemButton.sizeToFit()
        
        let leftNavigationBarButton = UIBarButtonItem(customView: leftNavigationItemButton)
        leftNavigationBarButton.accessibilityIdentifier = "Switch Site"
        
        navigationItem.leftBarButtonItems = [leftNavigationBarButton]
    }
    
    func editSwitchSiteButtonPressed() {
        let switchSiteViewController = SwitchSiteViewController()
        switchSiteViewController.view.backgroundColor = .clearColor()
        switchSiteViewController.modalPresentationStyle = .OverFullScreen
        switchSiteViewController.modalPresentationCapturesStatusBarAppearance = true
        presentViewController(switchSiteViewController, animated: true, completion: nil)
    }
    
    func animateTable() {
        tableView.reloadData()
        
        let navigationBar = navigationController?.navigationBar
        navigationBar?.transform = CGAffineTransformMakeTranslation(0, -80)
        navigationBar?.layer.opacity = 0.5
        
        let tabBar = tabBarController?.tabBar
        tabBar?.transform = CGAffineTransformMakeTranslation(0, 80)
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
                cell.transform = CGAffineTransformMakeTranslation(0, 0)
                }, completion: nil)
            
            index += 1
        }
    }
    
    func displayNoNetworkConnectionView() {
        view.addSubview(noInternetConnection)
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
            self.noInternetConnection.transform = CGAffineTransformMakeTranslation(0, self.topLayoutAnchor)
            }, completion: nil)
    }
    
}
