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
        
        let bounds = UIScreen.main.bounds
        let width = bounds.size.width
        
        activityIndicator.center = CGPoint(x: width / 2, y: 22)
        activityIndicator.color = .EDDBlueColor()
        
        return activityIndicator
    }()
    
    lazy var noInternetConnection: UIView = {
        let bounds: CGRect = UIScreen.main.bounds
        let width: CGFloat = bounds.width
        let height: CGFloat = 30.0
        
        let offlineView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        offlineView.backgroundColor = .errorColor()
        offlineView.transform = CGAffineTransform(translationX: 0, y: -80)
        offlineView.tag = 1
        
        let offlineLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
        offlineLabel.text = NSLocalizedString("No network connection", comment: "")
        offlineLabel.textColor = .white
        offlineLabel.textAlignment = .center
        
        offlineView.addSubview(offlineLabel)

        return offlineView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.backgroundColor = .EDDGreyColor()
    }
    
    fileprivate func setupSwitchSiteIcon() {
        let leftNavigationItemImage = UIImage(named: "NavigationBar-SwitchSite")
        let leftNavigationItemButton = HighlightButton(type: .custom)
        leftNavigationItemButton.tintColor = .white
        leftNavigationItemButton.setImage(leftNavigationItemImage, for: UIControlState())
        leftNavigationItemButton.addTarget(self, action: #selector(SiteTableViewController.switchSiteButtonPressed), for: .touchUpInside)
        leftNavigationItemButton.sizeToFit()
        
        let leftNavigationBarButton = UIBarButtonItem(customView: leftNavigationItemButton)
        leftNavigationBarButton.accessibilityIdentifier = "Switch Site"
        
        navigationItem.leftBarButtonItems = [leftNavigationBarButton]
    }
    
    func switchSiteButtonPressed() {
        let switchSiteViewController = SwitchSiteViewController()
        switchSiteViewController.view.backgroundColor = .clear
        
        let switchSiteNavigationController = UINavigationController(rootViewController: switchSiteViewController)
        if #available(iOS 11.0, *) {
            switchSiteNavigationController.navigationBar.prefersLargeTitles = true
        }
        switchSiteNavigationController.modalPresentationStyle = .overFullScreen
        switchSiteNavigationController.modalPresentationCapturesStatusBarAppearance = true
        present(switchSiteNavigationController, animated: true, completion: nil)
    }
    
    func animateTable() {
        tableView.reloadData()
        
        let navigationBar = navigationController?.navigationBar
        navigationBar?.transform = CGAffineTransform(translationX: 0, y: -80)
        navigationBar?.layer.opacity = 0.5
        
        let tabBar = tabBarController?.tabBar
        tabBar?.transform = CGAffineTransform(translationX: 0, y: 80)
        tabBar?.layer.opacity = 0.5
        
        let cells = tableView.visibleCells
        let tableHeight: CGFloat = tableView.bounds.size.height
        
        UIView.animate(withDuration: 0.5, animations: {
            navigationBar?.transform = CGAffineTransform(translationX: 0, y: 0)
            navigationBar?.layer.opacity = 1.0
            
            tabBar?.transform = CGAffineTransform(translationX: 0, y: 0)
            tabBar?.layer.opacity = 1.0
        }) 
        
        for i in cells {
            let cell: UITableViewCell = i as UITableViewCell
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        
        var index = 0
        
        for a in cells {
            let cell: UITableViewCell = a as UITableViewCell
            UIView.animate(withDuration: 1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
                }, completion: nil)
            
            index += 1
        }
    }
    
    func displayNoNetworkConnectionView() {
        view.addSubview(noInternetConnection)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
            self.noInternetConnection.transform = CGAffineTransform(translationX: 0, y: self.topLayoutAnchor)
            }, completion: nil)
    }
    
}
