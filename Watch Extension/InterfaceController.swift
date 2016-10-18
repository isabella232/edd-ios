//
//  InterfaceController.swift
//  Watch Extension
//
//  Created by Sunny Ratilal on 05/10/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import Alamofire
import SwiftyJSON

class InterfaceController: WKInterfaceController {

    struct Site {
        var name: String!
        var url: String!
        var key: String!
        var token: String!
    }
    
    @IBOutlet var tableView: WKInterfaceTable!
    
    var session: WCSession?
    
    var items = ["Active Site", "Today's Sales", "Current Month Sales", "Today's Earnings", "Current Month Earnings"]
    var data: [String] = [String]()
    
    var activeSite: [String: AnyObject] = [String: AnyObject]()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if WCSession.isSupported() {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        
        guard let activeSite = NSUserDefaults.standardUserDefaults().objectForKey("activeSite") as? [String: AnyObject] else {
            return
        }
        
        var activeSiteName = ""
        var activeSiteURL = ""
        var activeSiteKey = ""
        var activeSiteToken = ""
        
        for item in activeSite {
            if item.0 == "activeSiteName" {
                activeSiteName = item.1 as! String
            }
            
            if item.0 == "activeSiteURL" {
                activeSiteURL = item.1 as! String
            }
            
            if item.0 == "activeSiteKey" {
                activeSiteKey = item.1 as! String
            }
            
            if item.0 == "activeSiteToken" {
                activeSiteToken = item.1 as! String
            }
        }
        
        let site = Site(name: activeSiteName, url: activeSiteURL, key: activeSiteKey, token: activeSiteToken)
        
        data.append(site.name)
        data.append(site.name)
        data.append(site.name)
        data.append(site.name)
        data.append(site.name)
        data.append(site.name)
        
        let siteURL = site.url + "/edd-api/v2/stats"
        
        let parameters = ["key": site.key, "token": site.token]
        
        Alamofire.request(.GET, siteURL, parameters: parameters)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                if response.result.isSuccess {
                    let res = response.result.value!
                    NSUserDefaults.standardUserDefaults().setObject(res, forKey: "CachedStats")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    print(NSUserDefaults.standardUserDefaults().objectForKey("CachedStats") as? JSON)
                }
        }
        
        tableView.setNumberOfRows(items.count, withRowType: "DashboardRow")
        
        var i = 0
        for item in items {
            let row = tableView.rowControllerAtIndex(i) as! DashboardRowObject
            row.label.setText(item)
            row.statsLabel.setText(data[i])
            i += 1
        }
    }
    
    override init() {
        super.init()
        
        addMenuItemWithItemIcon(.Resume, title: NSLocalizedString("Refresh", comment: ""), action: #selector(InterfaceController.onRefreshIconTap))
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    override func didAppear() {
        super.didAppear()
    }

    internal func onRefreshIconTap() {
        
    }

    private func noSiteSetup () {
        tableView.setNumberOfRows(1, withRowType: "DashboardRow")
        
        let row = tableView.rowControllerAtIndex(0) as! DashboardRowObject
        row.label.setText("Error")
        row.statsLabel.setText("No sites have been set up. Please add a site from the iPhone app and try again.")
    }

    private func networkOperations() {
        
    }
    
    func tableRefresh(applicationContext: [String : AnyObject]) {
        data[0] = (NSUserDefaults.standardUserDefaults().objectForKey("activeSiteName")?.stringValue)!
        
        print(data)
        
        let row = tableView.rowControllerAtIndex(0) as! DashboardRowObject
        row.label.setText(items[0])
        row.statsLabel.setText(data[0])
    }

}

extension InterfaceController: WCSessionDelegate {

    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        NSUserDefaults.standardUserDefaults().setObject(userInfo, forKey: "activeSite")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        NSUserDefaults.standardUserDefaults().setObject(applicationContext, forKey: "activeSite")
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    func session(session: WCSession, activationDidCompleteWithState activationState: WCSessionActivationState, error: NSError?) {
        
    }

}
