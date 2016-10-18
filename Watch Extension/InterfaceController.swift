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

private let sharedNumberFormatter: NSNumberFormatter = {
    let formatter = NSNumberFormatter()
    formatter.numberStyle = .CurrencyStyle
    return formatter
}()

class InterfaceController: WKInterfaceController {

    struct Site {
        var name: String!
        var url: String!
        var key: String!
        var token: String!
        var currency: String!
    }
    
    @IBOutlet var tableView: WKInterfaceTable!
    
    var session: WCSession?
    
    var items = ["Active Site", "Today's Sales", "Current Month Sales", "Today's Earnings", "Current Month Earnings"]
    var data: [String] = [String]()
    
    var activeSite: [String: AnyObject] = [String: AnyObject]()
    
    var site: Site!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if WCSession.isSupported() {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        
        guard let activeSite = NSUserDefaults.standardUserDefaults().objectForKey("activeSite") as? [String: AnyObject] else {
            openiPhoneApp()
            return
        }
        
        var activeSiteName = ""
        var activeSiteURL = ""
        var activeSiteKey = ""
        var activeSiteToken = ""
        var activeSiteCurrency = ""
        
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
            
            if item.0 == "activeSiteCurrency" {
                activeSiteCurrency = item.1 as! String
            }
        }
        
        let site = Site(name: activeSiteName, url: activeSiteURL, key: activeSiteKey, token: activeSiteToken, currency: activeSiteCurrency)
        
        self.site = site
        
        sharedNumberFormatter.currencyCode = site.currency
        
        data.append(site.name)
        
        if let sales = NSUserDefaults.standardUserDefaults().objectForKey("sales") as? NSDictionary, let earnings = NSUserDefaults.standardUserDefaults().objectForKey("earnings") as? NSDictionary {
            self.data.append("\(sales["today"]!)")
            self.data.append("\(sales["current_month"]!)")
            self.data.append(sharedNumberFormatter.stringFromNumber(earnings["today"]!.doubleValue)!)
            self.data.append(sharedNumberFormatter.stringFromNumber(earnings["current_month"]!.doubleValue)!)
        } else {
            data.append("Loading...")
            data.append("Loading...")
            data.append("Loading...")
            data.append("Loading...")
        }
        
        let siteURL = site.url + "/edd-api/v2/stats"
        
        let parameters = ["key": site.key, "token": site.token]
        
        Alamofire.request(.GET, siteURL, parameters: parameters)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                if response.result.isSuccess {
                    let json = JSON(response.result.value!)

                    let earnings = NSDictionary(dictionary: json["stats"]["earnings"].dictionaryObject!)
                    let sales = NSDictionary(dictionary: json["stats"]["sales"].dictionaryObject!)
                    
                    self.data.removeAll(keepCapacity: false)
                    self.data.append(site.name)
                    
                    self.data.append(json["stats"]["sales"]["today"].stringValue)
                    self.data.append(json["stats"]["sales"]["current_month"].stringValue)
                    self.data.append(sharedNumberFormatter.stringFromNumber(json["stats"]["earnings"]["today"].doubleValue)!)
                    self.data.append(sharedNumberFormatter.stringFromNumber(json["stats"]["earnings"]["current_month"].doubleValue)!)
                    
                    NSUserDefaults.standardUserDefaults().setObject(earnings, forKey: "earnings")
                    NSUserDefaults.standardUserDefaults().setObject(sales, forKey: "sales")
                    
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    dispatch_async(dispatch_get_main_queue(), { 
                        self.tableRefresh()
                    })
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
        let siteURL = site.url + "/edd-api/v2/stats"
        
        let parameters = ["key": site.key, "token": site.token]
        
        Alamofire.request(.GET, siteURL, parameters: parameters)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                if response.result.isSuccess {
                    let json = JSON(response.result.value!)
                    
                    let earnings = NSDictionary(dictionary: json["stats"]["earnings"].dictionaryObject!)
                    let sales = NSDictionary(dictionary: json["stats"]["sales"].dictionaryObject!)
                    
                    self.data.removeAll(keepCapacity: false)
                    self.data.append(self.site.name)
                    
                    self.data.append(json["stats"]["sales"]["today"].stringValue)
                    self.data.append(json["stats"]["sales"]["current_month"].stringValue)
                    self.data.append(json["stats"]["earnings"]["today"].stringValue)
                    self.data.append(json["stats"]["earnings"]["current_month"].stringValue)
                    
                    NSUserDefaults.standardUserDefaults().setObject(earnings, forKey: "earnings")
                    NSUserDefaults.standardUserDefaults().setObject(sales, forKey: "sales")
                    
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableRefresh()
                    })
                }
        }
    }

    private func openiPhoneApp () {
        tableView.setNumberOfRows(1, withRowType: "DashboardRow")
        
        let row = tableView.rowControllerAtIndex(0) as! DashboardRowObject
        row.label.setText("Error")
        row.statsLabel.setText("Open the iPhone app to begin sync.")
    }
    
    private func noSiteSetup () {
        tableView.setNumberOfRows(1, withRowType: "DashboardRow")
        
        let row = tableView.rowControllerAtIndex(0) as! DashboardRowObject
        row.label.setText("Error")
        row.statsLabel.setText("No sites have been set up. Please add a site from the iPhone app and try again.")
    }
    
    func tableRefresh() {
        var i = 0
        for item in items {
            let row = tableView.rowControllerAtIndex(i) as! DashboardRowObject
            row.label.setText(item)
            row.statsLabel.setText(data[i])
            i += 1
        }
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
