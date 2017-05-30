//
//  SiteTabBarController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 23/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData

class SiteTabBarController: UITabBarController, UITabBarControllerDelegate, ManagedObjectContextSettable {
    
    var managedObjectContext: NSManagedObjectContext!
    
    var site: Site?
    
    var dashboardViewController: DashboardViewController?
    var dashboardNavigationController: UINavigationController?
    
    var salesViewController: SalesViewController?
    var salesNavigationController: UINavigationController?
    
    var customersViewController: CustomersViewController?
    var customersNavigationController: UINavigationController?
    
    var productsViewController: ProductsViewController?
    var productsNavigationController: UINavigationController?
    
    var moreViewController: MoreViewController?
    var moreViewNavigationController: UINavigationController?
    
    init(site: Site) {
        super.init(nibName: nil, bundle: nil)
        
        self.site = site
        
        self.managedObjectContext = AppDelegate.sharedInstance.managedObjectContext
        
        dashboardViewController = DashboardViewController(site: site)
        dashboardViewController?.managedObjectContext = managedObjectContext
        dashboardNavigationController = UINavigationController(rootViewController: dashboardViewController!)
        
        salesViewController = SalesViewController(site: site)
        salesViewController?.managedObjectContext = managedObjectContext
        salesNavigationController = UINavigationController(rootViewController: salesViewController!)
        
        productsViewController = ProductsViewController(site: site)
        productsViewController?.managedObjectContext = managedObjectContext
        productsNavigationController = UINavigationController(rootViewController: productsViewController!)
        
        customersViewController = CustomersViewController(site: site)
        customersViewController?.managedObjectContext = managedObjectContext
        customersNavigationController = UINavigationController(rootViewController: customersViewController!)
        
        moreViewController = MoreViewController(site: site)
        moreViewController?.managedObjectContext = managedObjectContext
        moreViewNavigationController = UINavigationController(rootViewController: moreViewController!)
        
        initViewControllers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.clipsToBounds = true
        self.view.backgroundColor = UIColor.white
        
        self.tabBar.isTranslucent = false
        
        self.delegate = self
    }
    
    func initViewControllers() {
        dashboardNavigationController!.tabBarItem.image = UIImage(named: "TabBar-Dashboard")
        salesNavigationController!.tabBarItem.image = UIImage(named: "TabBar-Sales")
        customersNavigationController!.tabBarItem.image = UIImage(named: "TabBar-Customers")
        productsNavigationController!.tabBarItem.image = UIImage(named: "TabBar-Products")
        moreViewNavigationController!.tabBarItem.image = UIImage(named: "TabBar-More")
        
        self.viewControllers = [dashboardNavigationController!, salesNavigationController!, customersNavigationController!, moreViewNavigationController!]
        
        self.viewControllers?.insert(productsNavigationController!, at: 3);
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if tabBarController.selectedViewController == viewController {
            if viewController.isKind(of: UINavigationController.self) {
                let navController = viewController as! UINavigationController
                if navController.topViewController == navController.viewControllers.first! && (navController.topViewController?.view.isKind(of: UITableView.self))! {
                    let tableView = navController.topViewController!.view as! UITableView
                    if tableView.numberOfSections > 0 && tableView.numberOfRows(inSection: 0) > 0 {
                        tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
                    }
                }
            }
        }
        
        return true
    }
    
}
