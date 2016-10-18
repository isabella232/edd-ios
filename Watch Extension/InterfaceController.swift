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
import SSKeychain

class InterfaceController: WKInterfaceController {

    @IBOutlet var tableView: WKInterfaceTable!
    
    var session: WCSession?
    
    var items = ["Active Site", "Today's Sales", "Current Month Sales", "Today's Earnings", "Current Month Earnings"]
    var data: [String] = [String]()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if WCSession.isSupported() {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        
        guard let activeSite = NSUserDefaults.standardUserDefaults().objectForKey("activeSite") else {
            return
        }
        
        tableView.setNumberOfRows(items.count, withRowType: "DashboardRow")
        
        var i = 0
        for item in items {
            let row = tableView.rowControllerAtIndex(i) as! DashboardRowObject
            row.label.setText(item)
//            row.statsLabel.setText(data[i])
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
