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

    let managedObjectContext = createEDDMainContext()

    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
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
        DDLog.addLogger(DDASLLogger())
        DDLog.addLogger(DDTTYLogger())
        DDLogVerbose("didFinishLaunchingWithOptions state: \(application.applicationState)")
        
//        let domainName = NSBundle.mainBundle().bundleIdentifier!
//        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(domainName)
        
        NetworkActivityIndicatorManager.sharedManager.isEnabled = true
        
        if self.noSitesSetup() {
            self.window?.rootViewController = LoginViewController()
        } else {
            EDDAPIWrapper.sharedInstance
            setupShortcutItems()
            self.window?.rootViewController = SiteTabBarController(site: Site.defaultSite())
        }
        
        guard let vc = window?.rootViewController as? ManagedObjectContextSettable else {
            fatalError("Wrong view controller type")
        }
        vc.managedObjectContext = managedObjectContext
        
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if url.scheme == "edd" {
            let components = (NSURLComponents(URL: url, resolvingAgainstBaseURL: false)?.queryItems)! as [NSURLQueryItem]
            
            let login = LoginViewController()
            login.fillInFields(components)
            
            self.window?.rootViewController = login
            
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
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
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
        guard let _ = NSUserDefaults.standardUserDefaults().objectForKey("defaultSite") as? String else {
            return true
        }

        return false
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
    }
    
    private func setupShortcutItems() {        
        let dashboardShortcutIcon = UIApplicationShortcutIcon(templateImageName: "ShortcutIcon-Dashboard")
        let salesShortcutIcon = UIApplicationShortcutIcon(templateImageName: "ShortcutIcon-Sales")
        let customersShortcutIcon = UIApplicationShortcutIcon(templateImageName: "ShortcutIcon-Customers")
        let reportsShortcutIcon = UIApplicationShortcutIcon(templateImageName: "ShortcutIcon-Reports")
        
        let dashboard = UIApplicationShortcutItem(type: "edd.dashboard", localizedTitle: "Dashboard", localizedSubtitle: "", icon: dashboardShortcutIcon, userInfo:nil)
        let sales = UIApplicationShortcutItem(type: "edd.sales", localizedTitle: "Sales", localizedSubtitle: "", icon: salesShortcutIcon, userInfo:nil)
        let customers = UIApplicationShortcutItem(type: "edd.customers", localizedTitle: "Customers", localizedSubtitle: "", icon: customersShortcutIcon, userInfo:nil)
        let reports = UIApplicationShortcutItem(type: "edd.reports", localizedTitle: "Reports", localizedSubtitle: "", icon: reportsShortcutIcon, userInfo:nil)
        
        UIApplication.sharedApplication().shortcutItems = [dashboard, sales, customers, reports]
        
    }
}