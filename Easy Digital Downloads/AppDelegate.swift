//
//  AppDelegate.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 22/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData
import CocoaLumberjack
import Alamofire
import AlamofireNetworkActivityIndicator
import SSKeychain

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    static let sharedInstance = AppDelegate()
    
    var window: UIWindow?
    
    var launchedShortcutItem: UIApplicationShortcutItem?


    let managedObjectContext = createEDDMainContext()
    
    let sharedDefaults: NSUserDefaults = NSUserDefaults(suiteName: "group.easydigitaldownloads.EDDSalesTracker")!

    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        // Handle 3D Touch
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
            launchedShortcutItem = shortcutItem
            handleShortcut(shortcutItem)
            return false
        }
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.backgroundColor = UIColor.whiteColor()
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        NSLog("File Directory: \(documentsPath)")
        
        let cache = NSURLCache.init(memoryCapacity: 8*1024*1024, diskCapacity: 20*1024*1024, diskPath: nil)
        NSURLCache.setSharedURLCache(cache)
        
        configureGlobalAppearance()
        
        return true
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Background Fetch
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)

        // Setup CocoaLumberjack
        DDLog.addLogger(DDASLLogger())
        DDLog.addLogger(DDTTYLogger())
        DDLogInfo("didFinishLaunchingWithOptions state: \(application.applicationState)")
        
        if sharedDefaults.boolForKey("DashboardLoaded") {
            sharedDefaults.setBool(false, forKey: "DashboardLoaded")
        }
        
//        let domainName = NSBundle.mainBundle().bundleIdentifier!
//        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(domainName)
        
        NetworkActivityIndicatorManager.sharedManager.isEnabled = true
        
        if self.noSitesSetup() {
            self.window?.rootViewController = LoginViewController()
        } else {
            EDDAPIWrapper.sharedInstance
            setupShortcutItems()
            self.window?.rootViewController = SiteTabBarController(site: Site.activeSite())
        }
        
        guard let vc = self.window?.rootViewController as? ManagedObjectContextSettable else {
            fatalError("Wrong view controller type")
        }
        vc.managedObjectContext = managedObjectContext
        
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if url.scheme == "edd" {
            if url.URLString == "edd://dashboard" {
                EDDAPIWrapper.sharedInstance
                setupShortcutItems()
                self.window?.rootViewController = SiteTabBarController(site: Site.activeSite())
                return true
            }
            
            let components = (NSURLComponents(URL: url, resolvingAgainstBaseURL: false)?.queryItems)! as [NSURLQueryItem]
            
            let login = LoginViewController()
            self.window?.rootViewController = login
            guard let vc = self.window?.rootViewController as? ManagedObjectContextSettable else {
                fatalError("Wrong view controller type")
            }
            vc.managedObjectContext = managedObjectContext            
            login.fillInFields(components)

            return true
        }
        
        return false
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        managedObjectContext.refreshAllObjects()
        managedObjectContext.performSaveOrRollback()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        guard let shortcut = launchedShortcutItem else { return }
        
        handleShortcut(shortcut)
        
        launchedShortcutItem = nil
    }
    
    func applicationDidReceiveMemoryWarning(application: UIApplication) {
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        managedObjectContext.refreshAllObjects()
    }

    func applicationWillTerminate(application: UIApplication) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        managedObjectContext.performSaveOrRollback()
    }
    
    func noSitesSetup() -> Bool {
        guard let _ = sharedDefaults.objectForKey("defaultSite") as? String,
              let _ = Site.hasActiveSite() else {
            return true
        }

        return false
    }
    
    func switchActiveSite(siteID: String) {
        sharedDefaults.setValue(siteID, forKey: "defaultSite")
        sharedDefaults.setValue(siteID, forKey: "activeSite")
        sharedDefaults.synchronize()
        sharedDefaults.setValue(Site.activeSite().name, forKey: "activeSiteName")
        sharedDefaults.setValue(Site.activeSite().currency, forKey: "activeSiteCurrency")
        sharedDefaults.setValue(Site.activeSite().url, forKey: "activeSiteURL")
        sharedDefaults.synchronize()
        EDDAPIWrapper.sharedInstance.refreshActiveSite()
    }
    
    func handleNoActiveSite() {
        self.window?.rootViewController = LoginViewController()
    }
    
    // MARK: Private
    
    private func configureGlobalAppearance() {
        let navigationBar = UINavigationBar.appearance()
        navigationBar.translucent = false
        navigationBar.barStyle = .BlackTranslucent
        navigationBar.tintColor = .whiteColor()
        navigationBar.barTintColor = .EDDBlackColor()
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        let tabBar = UITabBar.appearance()
        tabBar.tintColor = .EDDBlueColor()
        
        let tableView = UITableView.appearance()
        tableView.backgroundColor = .EDDGreyColor()
        
        let selectionView = UIView()
        selectionView.backgroundColor = .tableViewCellHighlightColor()
        UITableViewCell.appearance().selectedBackgroundView = selectionView
    }
    
    // MARK: 3D Touch
    
    private func setupShortcutItems() {        
        let dashboardShortcutIcon = UIApplicationShortcutIcon(templateImageName: "ShortcutIcon-Dashboard")
        let salesShortcutIcon = UIApplicationShortcutIcon(templateImageName: "ShortcutIcon-Sales")
        let customersShortcutIcon = UIApplicationShortcutIcon(templateImageName: "ShortcutIcon-Customers")
        let reportsShortcutIcon = UIApplicationShortcutIcon(templateImageName: "ShortcutIcon-Reports")
        
        let dashboard = UIApplicationShortcutItem(type: "edd.dashboard", localizedTitle: "Dashboard", localizedSubtitle: "", icon: dashboardShortcutIcon, userInfo:nil)
        let sales = UIApplicationShortcutItem(type: "edd.sales", localizedTitle: "Sales", localizedSubtitle: "", icon: salesShortcutIcon, userInfo:nil)
        let customers = UIApplicationShortcutItem(type: "edd.customers", localizedTitle: "Customers", localizedSubtitle: "", icon: customersShortcutIcon, userInfo:nil)
        let reports = UIApplicationShortcutItem(type: "edd.prodcuts", localizedTitle: "Products", localizedSubtitle: "", icon: reportsShortcutIcon, userInfo:nil)
        
        UIApplication.sharedApplication().shortcutItems = [dashboard, sales, customers, reports]
    }
    
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        completionHandler(handleShortcut(shortcutItem))
    }
    
    private func handleShortcut(shortcutItem: UIApplicationShortcutItem) -> Bool {
        guard let shortCutType = shortcutItem.type as String? else {
            return false
        }
        
        EDDAPIWrapper.sharedInstance
        
        guard let _ = self.window?.rootViewController as? SiteTabBarController else {
            return false
        }
        
        if shortCutType == "edd.dashboard"  {
            EDDAPIWrapper.sharedInstance
            (self.window?.rootViewController as! SiteTabBarController).selectedIndex = 0
        }
        
        if shortcutItem == "edd.sales" {
            EDDAPIWrapper.sharedInstance
            (self.window?.rootViewController as! SiteTabBarController).selectedIndex = 1
        }
        
        if shortcutItem == "edd.customers" {
            EDDAPIWrapper.sharedInstance
            (self.window?.rootViewController as! SiteTabBarController).selectedIndex = 2
        }
        
        if shortcutItem == "edd.products" {
            EDDAPIWrapper.sharedInstance
            (self.window?.rootViewController as! SiteTabBarController).selectedIndex = 3
        }
        
        return true
    }
}
