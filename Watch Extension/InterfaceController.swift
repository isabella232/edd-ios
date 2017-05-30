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

private let sharedNumberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
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
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if WCSession.isSupported() {
            let session = WCSession.default()
            session.delegate = self
            session.activate()
        }
        
        guard let activeSite = UserDefaults.standard.object(forKey: "activeSite") as? [String: AnyObject] else {
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
        
        if let sales = UserDefaults.standard.object(forKey: "sales") as? NSDictionary, let earnings = UserDefaults.standard.object(forKey: "earnings") as? NSDictionary {
            self.data.append("\(sales["today"]!)")
            self.data.append("\(sales["current_month"]!)")
            self.data.append(sharedNumberFormatter.string(from: (earnings["today"]! as AnyObject).doubleValue! as NSNumber)!)
            self.data.append(sharedNumberFormatter.string(from: (earnings["current_month"]! as AnyObject).doubleValue! as NSNumber)!)
        } else {
            data.append("Loading...")
            data.append("Loading...")
            data.append("Loading...")
            data.append("Loading...")
        }
        
        let siteURL = site.url + "/edd-api/v2/stats"
        
        Alamofire.request(siteURL, method: .get, parameters: ["key": site.key, "token": site.token], encoding: JSONEncoding.default, headers: nil)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                if response.result.isSuccess {
                    let json = JSON(response.result.value!)

                    let earnings = NSDictionary(dictionary: json["stats"]["earnings"].dictionaryObject!)
                    let sales = NSDictionary(dictionary: json["stats"]["sales"].dictionaryObject!)
                    
                    self.data.removeAll(keepingCapacity: false)
                    self.data.append(self.site.name)
                    
                    self.data.append(json["stats"]["sales"]["today"].stringValue)
                    self.data.append(json["stats"]["sales"]["current_month"].stringValue)
                    self.data.append(sharedNumberFormatter.string(from: NSNumber(value: json["stats"]["earnings"]["today"].doubleValue))!)
                    self.data.append(sharedNumberFormatter.string(from: NSNumber(value: json["stats"]["earnings"]["current_month"].doubleValue))!)
                    
                    UserDefaults.standard.set(earnings, forKey: "earnings")
                    UserDefaults.standard.set(sales, forKey: "sales")
                    
                    UserDefaults.standard.synchronize()
                    
                    DispatchQueue.main.async(execute: {
                        self.tableRefresh()
                    })
                }
        }
        
        tableView.setNumberOfRows(items.count, withRowType: "DashboardRow")
        
        var i = 0
        for item in items {
            let row = tableView.rowController(at: i) as! DashboardRowObject
            row.label.setText(item)
            row.statsLabel.setText(data[i])
            i += 1
        }
    }
    
    override init() {
        super.init()
        
        addMenuItem(with: .resume, title: NSLocalizedString("Refresh", comment: ""), action: #selector(InterfaceController.onRefreshIconTap))
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

    func onRefreshIconTap() {
        let siteURL = site.url + "/edd-api/v2/stats"
        
        Alamofire.request(siteURL, method: .get, parameters: ["key": site.key, "token": site.token], encoding: JSONEncoding.default, headers: nil)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                if response.result.isSuccess {
                    let json = JSON(response.result.value!)
                    
                    let earnings = NSDictionary(dictionary: json["stats"]["earnings"].dictionaryObject!)
                    let sales = NSDictionary(dictionary: json["stats"]["sales"].dictionaryObject!)
                    
                    self.data.removeAll(keepingCapacity: false)
                    self.data.append(self.site.name)
                    
                    self.data.append(json["stats"]["sales"]["today"].stringValue)
                    self.data.append(json["stats"]["sales"]["current_month"].stringValue)
                    self.data.append(sharedNumberFormatter.string(from: NSNumber(value: json["stats"]["earnings"]["today"].doubleValue))!)
                    self.data.append(sharedNumberFormatter.string(from: NSNumber(value: json["stats"]["earnings"]["current_month"].doubleValue))!)
                    
                    UserDefaults.standard.set(earnings, forKey: "earnings")
                    UserDefaults.standard.set(sales, forKey: "sales")
                    
                    UserDefaults.standard.synchronize()
                    
                    DispatchQueue.main.async(execute: {
                        self.tableRefresh()
                    })
                }
        }
    }

    fileprivate func openiPhoneApp () {
        tableView.setNumberOfRows(1, withRowType: "DashboardRow")
        
        let row = tableView.rowController(at: 0) as! DashboardRowObject
        row.label.setText("Error")
        row.statsLabel.setText("Open the iPhone app to begin sync.")
    }
    
    fileprivate func noSiteSetup () {
        tableView.setNumberOfRows(1, withRowType: "DashboardRow")
        
        let row = tableView.rowController(at: 0) as! DashboardRowObject
        row.label.setText("Error")
        row.statsLabel.setText("No sites have been set up. Please add a site from the iPhone app and try again.")
    }
    
    func tableRefresh() {
        var i = 0
        
        tableView.setNumberOfRows(items.count, withRowType: "DashboardRow")
        
        for item in items {
            let row = tableView.rowController(at: i) as! DashboardRowObject
            row.label.setText(item)
            row.statsLabel.setText(data[i])
            i += 1
        }
    }

}

extension InterfaceController: WCSessionDelegate {

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        UserDefaults.standard.set(userInfo, forKey: "activeSite")
        UserDefaults.standard.synchronize()
        
        var activeSiteName = ""
        var activeSiteURL = ""
        var activeSiteKey = ""
        var activeSiteToken = ""
        var activeSiteCurrency = ""
        
        for item in userInfo {
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
        
        self.data.removeAll(keepingCapacity: false)
        self.data.append(self.site.name)
        self.data.append("Loading...")
        self.data.append("Loading...")
        self.data.append("Loading...")
        self.data.append("Loading...")
        
        onRefreshIconTap()
        
        DispatchQueue.main.async { 
            self.tableRefresh()
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        UserDefaults.standard.set(applicationContext, forKey: "activeSite")
        UserDefaults.standard.synchronize()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }

}
