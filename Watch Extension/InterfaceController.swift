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
    
    var session: WCSession!
    
    let sharedDefaults: NSUserDefaults = NSUserDefaults(suiteName: "group.easydigitaldownloads.EDDSalesTracker")!
    
    var items = ["Active Site", "Today's Sales", "Current Month Sales", "Today's Earnings", "Current Month Earnings"]
    var data: [String] = [String]()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        guard let siteName = sharedDefaults.stringForKey("activeSiteName") else {
            noSiteSetup()
            return
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
    
    internal func onRefreshIconTap() {
        
    }
    
    private func noSiteSetup () {
        tableView.setNumberOfRows(1, withRowType: "DashboardRow")
        
        let row = tableView.rowControllerAtIndex(0) as! DashboardRowObject
        row.label.setText("Error")
        row.statsLabel.setText("No sites have been set up. Please add a site from the iPhone app and try again.")
    }
    
    private func networkOperations() {
        guard let defaultSite = sharedDefaults.objectForKey("defaultSite") as? String else {
            return
        }
        
        let auth = SSKeychain.accountsForService(defaultSite)
        let data = auth[0] as NSDictionary
        let acct = data.objectForKey("acct") as! String
        let password = SSKeychain.passwordForService(defaultSite, account: acct)
        
        let siteURL = sharedDefaults.stringForKey("activeSiteURL")! + "/edd-api/v2/stats"
        
        let parameters = ["key": acct, "token": password]
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.currencyCode = sharedDefaults.stringForKey("activeSiteCurrency")!
        
        Alamofire.request(.GET, siteURL, parameters: parameters)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                if response.result.isSuccess {
                    let resJSON = JSON(response.result.value!)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                    })
                }
                
                if response.result.isFailure {
                }
        }
        
    }


}
