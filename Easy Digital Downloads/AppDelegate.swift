//
//  AppDelegate.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 22/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import AlamofireNetworkActivityIndicator
import SSKeychain
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    static let sharedInstance = AppDelegate()
    
    var window: UIWindow?
    
    var session: WCSession? {
        didSet {
            if let session = session {
                session.delegate = self
                session.activate()
            }
        }
    }
    
    var launchedShortcutItem: UIApplicationShortcutItem?

    let managedObjectContext = createEDDMainContext()
    
    let sharedDefaults: UserDefaults = UserDefaults(suiteName: "group.easydigitaldownloads.EDDSalesTracker")!

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Handle 3D Touch
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            launchedShortcutItem = shortcutItem
            handleShortcut(shortcutItem)
            return false
        }
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.white
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        NSLog("File Directory: \(documentsPath)")
        
        let capacity = 500 * 1024 * 1024
        
        let cache = URLCache(memoryCapacity: capacity, diskCapacity: capacity, diskPath: "shared_url_cache")
        URLCache.shared = cache
        
        configureGlobalAppearance()
        
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Background Fetch
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)

        if WCSession.isSupported() {
            session = WCSession.default()
            session?.delegate = self
            session?.activate()
        }
        
        if sharedDefaults.bool(forKey: "DashboardLoaded") {
            sharedDefaults.set(false, forKey: "DashboardLoaded")
        }
        
//        let domainName = NSBundle.mainBundle().bundleIdentifier!
//        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(domainName)
        
        NetworkActivityIndicatorManager.shared.isEnabled = true
        
        if self.noSitesSetup() {
            self.window?.rootViewController = LoginViewController()
        } else {
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
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if url.scheme == "edd" {
            if url.absoluteString == "edd://dashboard" {
                setupShortcutItems()
                self.window?.rootViewController = SiteTabBarController(site: Site.activeSite())
                return true
            }
            
            let components = (URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems)! as [URLQueryItem]
            
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

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        managedObjectContext.refreshAllObjects()
        managedObjectContext.performSaveOrRollback()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        guard let shortcut = launchedShortcutItem else { return }
        
        handleShortcut(shortcut)
        
        launchedShortcutItem = nil
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        URLCache.shared.removeAllCachedResponses()
        managedObjectContext.refreshAllObjects()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        NotificationCenter.default.removeObserver(self)
        managedObjectContext.performSaveOrRollback()
    }
    
    func noSitesSetup() -> Bool {
        guard let _ = sharedDefaults.object(forKey: "defaultSite") as? String,
              let _ = Site.hasActiveSite() else {
            return true
        }

        return false
    }
    
    func switchActiveSite(_ siteID: String) {
        sharedDefaults.setValue(siteID, forKey: "defaultSite")
        sharedDefaults.setValue(siteID, forKey: "activeSite")
        sharedDefaults.synchronize()
        sharedDefaults.setValue(Site.activeSite().name, forKey: "activeSiteName")
        sharedDefaults.setValue(Site.activeSite().currency, forKey: "activeSiteCurrency")
        sharedDefaults.setValue(Site.activeSite().url, forKey: "activeSiteURL")
        sharedDefaults.synchronize()
        EDDAPIWrapper.sharedInstance.refreshActiveSite()
        
        if WCSession.isSupported() {
            print("Sending data to Watch...")
            let watchSession = WCSession.default()
            watchSession.delegate = self
            watchSession.activate()
            if watchSession.isPaired && watchSession.isWatchAppInstalled {
                do {
                    let userInfo = [
                        "activeSiteName": Site.activeSite().name!,
                        "activeSiteURL" : Site.activeSite().url!,
                        "activeSiteKey" : Site.activeSite().key,
                        "activeSiteToken" : Site.activeSite().token,
                        "activeSiteCurrency" : Site.activeSite().currency!
                    ]
                    try watchSession.transferUserInfo(userInfo)
                } catch let error as NSError {
                    print(error.description)
                }
            }
        }
    }
    
    func handleNoActiveSite() {
        self.window?.rootViewController = LoginViewController()
    }
    
    // MARK: Private
    
    fileprivate func configureGlobalAppearance() {
        let navigationBar = UINavigationBar.appearance()
        navigationBar.isTranslucent = false
        navigationBar.barStyle = .blackTranslucent
        navigationBar.tintColor = .white
        navigationBar.barTintColor = .EDDBlackColor()
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        let tabBar = UITabBar.appearance()
        tabBar.tintColor = .EDDBlueColor()
        
        let tableView = UITableView.appearance()
        tableView.backgroundColor = .EDDGreyColor()
        
        let selectionView = UIView()
        selectionView.backgroundColor = .tableViewCellHighlightColor()
        UITableViewCell.appearance().selectedBackgroundView = selectionView
    }
    
    // MARK: 3D Touch
    
    fileprivate func setupShortcutItems() {        
        let dashboardShortcutIcon = UIApplicationShortcutIcon(templateImageName: "ShortcutIcon-Dashboard")
        let salesShortcutIcon = UIApplicationShortcutIcon(templateImageName: "ShortcutIcon-Sales")
        let customersShortcutIcon = UIApplicationShortcutIcon(templateImageName: "ShortcutIcon-Customers")
        let reportsShortcutIcon = UIApplicationShortcutIcon(templateImageName: "ShortcutIcon-Reports")
        
        let dashboard = UIApplicationShortcutItem(type: "edd.dashboard", localizedTitle: "Dashboard", localizedSubtitle: "", icon: dashboardShortcutIcon, userInfo:nil)
        let sales = UIApplicationShortcutItem(type: "edd.sales", localizedTitle: "Sales", localizedSubtitle: "", icon: salesShortcutIcon, userInfo:nil)
        let customers = UIApplicationShortcutItem(type: "edd.customers", localizedTitle: "Customers", localizedSubtitle: "", icon: customersShortcutIcon, userInfo:nil)
        let reports = UIApplicationShortcutItem(type: "edd.prodcuts", localizedTitle: "Products", localizedSubtitle: "", icon: reportsShortcutIcon, userInfo:nil)
        
        UIApplication.shared.shortcutItems = [dashboard, sales, customers, reports]
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleShortcut(shortcutItem))
    }
    
    @discardableResult
    fileprivate func handleShortcut(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        guard let _ = self.window?.rootViewController as? SiteTabBarController else {
            return false
        }
        
        if shortcutItem.type == "edd.dashboard"  {
            (self.window?.rootViewController as! SiteTabBarController).selectedIndex = 0
        }
        
        if shortcutItem.type == "edd.sales" {
            (self.window?.rootViewController as! SiteTabBarController).selectedIndex = 1
        }
        
        if shortcutItem.type == "edd.customers" {
            (self.window?.rootViewController as! SiteTabBarController).selectedIndex = 2
        }
        
        if shortcutItem.type == "edd.products" {
            (self.window?.rootViewController as! SiteTabBarController).selectedIndex = 3
        }
        
        return true
    }
}

extension AppDelegate: WCSessionDelegate {
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print(message)
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sendActiveSiteData() {
        
    }
    
}
