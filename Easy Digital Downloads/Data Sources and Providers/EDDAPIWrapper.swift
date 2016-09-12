//
//  EDDAPIWrapper.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 31/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Alamofire
import SwiftyJSON

public final class EDDAPIWrapper: NSObject {
    
    public static let sharedInstance: EDDAPIWrapper = {
        return EDDAPIWrapper()
    }()
    
    private let managedObjectContext: NSManagedObjectContext!
    private let site: Site!
    
    private enum Endpoints: String {
        case Base = "/edd-api/"
        case Version = "v2/"
        case Stats = "stats"
        case Sales = "sales"
        case Earnings = "earnings"
        case Commissions = "commissions"
        case StoreCommissions = "store-commissions"
        case Reviews = "reviews"
        case Subscriptions = "subscriptions"
        case Info = "info"
        case Customers = "customers"
        case Logs = "file-download-logs"
        case Products = "products"
    }
    
    private override init() {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        site = Site.defaultSite()
    }
    
    public func requestStats(parameters: [String : AnyObject], success:(JSON) -> Void, failure:(NSError) -> Void) {
        let baseURL = site.url! + Endpoints.Base.rawValue + Endpoints.Version.rawValue + Endpoints.Stats.rawValue
        requestGETURL(baseURL, parameters: parameters, success: { (response) -> Void in
            success(response)
        }) { (error) -> Void in
            failure(error)
        }
    }
    
    public func requestSalesStatsGraphData(success:(JSON) -> Void, failure:(NSError) -> Void) {
        let baseURL = site.url! + Endpoints.Base.rawValue + Endpoints.Version.rawValue + Endpoints.Stats.rawValue
        
        let sevenDaysAgo = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: -6, toDate: NSDate(), options: [])! as NSDate
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let startDate = dateFormatter.stringFromDate(sevenDaysAgo)
        let endDate = dateFormatter.stringFromDate(NSDate())
        
        requestGETURL(baseURL, parameters: ["type" : "sales", "date" : "range", "startdate" : startDate, "enddate" : endDate], success: { (response) -> Void in
            success(response)
        }) { (error) -> Void in
            failure(error)
        }
    }
    
    public func requestEarningsStatsGraphData(success:(JSON) -> Void, failure:(NSError) -> Void) {
        let baseURL = site.url! + Endpoints.Base.rawValue + Endpoints.Version.rawValue + Endpoints.Stats.rawValue
        
        let sevenDaysAgo = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: -6, toDate: NSDate(), options: [])! as NSDate
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let startDate = dateFormatter.stringFromDate(sevenDaysAgo)
        let endDate = dateFormatter.stringFromDate(NSDate())
        
        requestGETURL(baseURL, parameters: ["type" : "earnings", "date" : "range", "startdate" : startDate, "enddate" : endDate], success: { (response) -> Void in
            success(response)
        }) { (error) -> Void in
            failure(error)
        }
    }
    
    public func requestSales(parameters: [String : AnyObject], success:(JSON) -> Void, failure:(NSError) -> Void) {
        let baseURL = site.url! + Endpoints.Base.rawValue + Endpoints.Version.rawValue + Endpoints.Sales.rawValue
        
        requestGETURL(baseURL, parameters: parameters, success: { (response) -> Void in
            success(response)
        }) { (error) -> Void in
            failure(error)
        }
    }
    
    public func requestEarnings(parameters: [String : AnyObject], success:(JSON) -> Void, failure:(NSError) -> Void) {
        let baseURL = site.url! + Endpoints.Base.rawValue + Endpoints.Version.rawValue + Endpoints.Earnings.rawValue
        requestGETURL(baseURL, parameters: parameters, success: { (response) -> Void in
            success(response)
        }) { (error) -> Void in
            failure(error)
        }
    }
    
    public func requestCommissions(parameters: [String : AnyObject], success:(JSON) -> Void, failure:(NSError) -> Void) {
        let baseURL = site.url! + Endpoints.Base.rawValue + Endpoints.Version.rawValue + Endpoints.Commissions.rawValue
        requestGETURL(baseURL, parameters: parameters, success: { (response) -> Void in
            success(response)
        }) { (error) -> Void in
            failure(error)
        }
    }
    
    public func requestStoreCommissions(parameters: [String : AnyObject], success:(JSON) -> Void, failure:(NSError) -> Void) {
        let baseURL = site.url! + Endpoints.Base.rawValue + Endpoints.Version.rawValue + Endpoints.StoreCommissions.rawValue
        requestGETURL(baseURL, parameters: parameters, success: { (response) -> Void in
            success(response)
        }) { (error) -> Void in
            failure(error)
        }
    }
    
    public func requestCustomers(parameters: [String : AnyObject], success:(JSON) -> Void, failure:(NSError) -> Void) {
        let baseURL = site.url! + Endpoints.Base.rawValue + Endpoints.Version.rawValue + Endpoints.Customers.rawValue
        requestGETURL(baseURL, parameters: parameters, success: { (response) -> Void in
            success(response)
        }) { (error) -> Void in
            failure(error)
        }
    }
    
    public func requestProducts(parameters: [String : AnyObject], success:(JSON) -> Void, failure:(NSError) -> Void) {
        let baseURL = site.url! + Endpoints.Base.rawValue + Endpoints.Version.rawValue + Endpoints.Products.rawValue
        requestGETURL(baseURL, parameters: parameters, success: { (response) -> Void in
            success(response)
        }) { (error) -> Void in
            failure(error)
        }
    }
    
    public func requestReviews(parameters: [String : AnyObject], success:(JSON) -> Void, failure:(NSError) -> Void) {
        let baseURL = site.url! + Endpoints.Base.rawValue + Endpoints.Version.rawValue + Endpoints.Reviews.rawValue
        requestGETURL(baseURL, parameters: parameters, success: { (response) -> Void in
            success(response)
        }) { (error) -> Void in
            failure(error)
        }
    }
    
    public func requestFileDownloadLogs(parameters: [String : AnyObject], success:(JSON) -> Void, failure:(NSError) -> Void) {
        let baseURL = site.url! + Endpoints.Base.rawValue + Endpoints.Version.rawValue + Endpoints.Logs.rawValue
        requestGETURL(baseURL, parameters: parameters, success: { (response) -> Void in
            success(response)
        }) { (error) -> Void in
            failure(error)
        }
    }
    
    public func requestSubscriptions(parameters: [String : AnyObject], success:(JSON) -> Void, failure:(NSError) -> Void) {
        let baseURL = site.url! + Endpoints.Base.rawValue + Endpoints.Version.rawValue + Endpoints.Subscriptions.rawValue
        requestGETURL(baseURL, parameters: parameters, success: { (response) -> Void in
            success(response)
        }) { (error) -> Void in
            failure(error)
        }
    }
    
    public func requestGETURL(strURL: String, parameters: [String: AnyObject], success:(JSON) -> Void, failure:(NSError) -> Void) {
        let auth : [String : AnyObject] = ["key": site.key, "token": site.token, "number" : 20]
        var passedParameters : [String: AnyObject] = auth

        passedParameters.update(parameters)
        
        Alamofire.request(.GET, strURL, parameters: passedParameters)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                if response.result.isSuccess {
                    let resJSON = JSON(response.result.value!)
                    success(resJSON)
                }
                
                if response.result.isFailure {
                    let error: NSError = response.result.error!
                    failure(error)
                }
        }
    }
    
    public func hasRecurringPaymentsIntegration() -> Bool {
        let baseURL = site.url! + Endpoints.Base.rawValue + Endpoints.Version.rawValue + Endpoints.Subscriptions.rawValue
        var ret: Bool = false

        requestGETURL(baseURL, parameters: [:], success: { (response) -> Void in
            ret = true
        }) { (error) -> Void in
            ret = false
        }
        
        return ret
    }

}
