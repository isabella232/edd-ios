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
    
    fileprivate let managedObjectContext: NSManagedObjectContext!
    var site: Site!
    
    fileprivate enum Endpoints: String {
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
        case Discounts = "discounts"
    }
    
    var requests: [Request] = [Request]()
    
    fileprivate override init() {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        site = Site.activeSite()
    }
    
    public func refreshActiveSite() {
        site = Site.activeSite()
    }
    
    public func cancelAllRequests() {
        requests.forEach { $0.cancel() }
    }
    
    public func requestStats(_ parameters: [String : AnyObject], success:@escaping (JSON) -> Void, failure:@escaping (NSError) -> Void) {
        let baseURL = site.url! + Endpoints.Base.rawValue + Endpoints.Version.rawValue + Endpoints.Stats.rawValue
        requestGETURL(baseURL, parameters: parameters, success: { (response) -> Void in
            success(response)
        }) { (error) -> Void in
            failure(error)
        }
    }
    
    public func requestSalesStatsGraphData(_ success:@escaping (JSON) -> Void, failure:@escaping (NSError) -> Void) {
        let baseURL = site.url! + Endpoints.Base.rawValue + Endpoints.Version.rawValue + Endpoints.Stats.rawValue
        
        let sevenDaysAgo = (Calendar.current as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: -6, to: Date(), options: [])! as Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let startDate = dateFormatter.string(from: sevenDaysAgo)
        let endDate = dateFormatter.string(from: Date())
        
        let paramaters : Parameters = ["type" : "sales", "date" : "range", "startdate" : startDate, "enddate" : endDate]

        requestGETURL(baseURL, parameters: paramaters, success: { (response) -> Void in
            success(response)
        }) { (error) -> Void in
            failure(error)
        }
    }
    
    public func requestEarningsStatsGraphData(_ success:@escaping (JSON) -> Void, failure:@escaping (NSError) -> Void) {
        let baseURL = site.url! + Endpoints.Base.rawValue + Endpoints.Version.rawValue + Endpoints.Stats.rawValue
        
        let sevenDaysAgo = (Calendar.current as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: -6, to: Date(), options: [])! as Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let startDate = dateFormatter.string(from: sevenDaysAgo)
        let endDate = dateFormatter.string(from: Date())
        
        let parameters : Parameters = ["type" : "earnings", "date" : "range", "startdate" : startDate, "enddate" : endDate]

        requestGETURL(baseURL, parameters: parameters, success: { (response) -> Void in
            success(response)
        }) { (error) -> Void in
            failure(error)
        }
    }
    
    public func requestSales(_ parameters: [String : AnyObject], success:@escaping (JSON) -> Void, failure:@escaping (NSError) -> Void) {
        let baseURL = site.url! + Endpoints.Base.rawValue + Endpoints.Version.rawValue + Endpoints.Sales.rawValue
        
        requestGETURL(baseURL, parameters: parameters, success: { (response) -> Void in
            success(response)
        }) { (error) -> Void in
            failure(error)
        }
    }
    
    public func requestEarnings(_ parameters: [String : AnyObject], success:@escaping (JSON) -> Void, failure:@escaping (NSError) -> Void) {
        let baseURL = site.url! + Endpoints.Base.rawValue + Endpoints.Version.rawValue + Endpoints.Earnings.rawValue
        requestGETURL(baseURL, parameters: parameters, success: { (response) -> Void in
            success(response)
        }) { (error) -> Void in
            failure(error)
        }
    }
    
    public func requestCommissions(_ parameters: [String : AnyObject], success:@escaping (JSON) -> Void, failure:@escaping (NSError) -> Void) {
        let baseURL = site.url! + Endpoints.Base.rawValue + Endpoints.Version.rawValue + Endpoints.Commissions.rawValue
        requestGETURL(baseURL, parameters: parameters, success: { (response) -> Void in
            success(response)
        }) { (error) -> Void in
            failure(error)
        }
    }
    
    public func requestStoreCommissions(_ parameters: [String : AnyObject], success:@escaping (JSON) -> Void, failure:@escaping (NSError) -> Void) {
        let baseURL = site.url! + Endpoints.Base.rawValue + Endpoints.Version.rawValue + Endpoints.StoreCommissions.rawValue
        requestGETURL(baseURL, parameters: parameters, success: { (response) -> Void in
            success(response)
        }) { (error) -> Void in
            failure(error)
        }
    }
    
    public func requestCustomers(_ parameters: [String : AnyObject], success:@escaping (JSON) -> Void, failure:@escaping (NSError) -> Void) {
        let baseURL = site.url! + Endpoints.Base.rawValue + Endpoints.Version.rawValue + Endpoints.Customers.rawValue
        requestGETURL(baseURL, parameters: parameters, success: { (response) -> Void in
            success(response)
        }) { (error) -> Void in
            failure(error)
        }
    }
    
    public func requestProducts(_ parameters: [String : AnyObject], success:@escaping (JSON) -> Void, failure:@escaping (NSError) -> Void) {
        let baseURL = site.url! + Endpoints.Base.rawValue + Endpoints.Products.rawValue
        requestGETURL(baseURL, parameters: parameters, success: { (response) -> Void in
            success(response)
        }) { (error) -> Void in
            failure(error)
        }
    }
    
    public func requestReviews(_ parameters: [String : AnyObject], success:@escaping (JSON) -> Void, failure:@escaping (NSError) -> Void) {
        let baseURL = site.url! + Endpoints.Base.rawValue + Endpoints.Version.rawValue + Endpoints.Reviews.rawValue
        requestGETURL(baseURL, parameters: parameters, success: { (response) -> Void in
            success(response)
        }) { (error) -> Void in
            failure(error)
        }
    }
    
    public func requestFileDownloadLogs(_ parameters: [String : AnyObject], success:@escaping (JSON) -> Void, failure:@escaping (NSError) -> Void) {
        let baseURL = site.url! + Endpoints.Base.rawValue + Endpoints.Version.rawValue + Endpoints.Logs.rawValue
        requestGETURL(baseURL, parameters: parameters, success: { (response) -> Void in
            success(response)
        }) { (error) -> Void in
            failure(error)
        }
    }
    
    public func requestSubscriptions(_ parameters: [String : AnyObject], success:@escaping (JSON) -> Void, failure:@escaping (NSError) -> Void) {
        let baseURL = site.url! + Endpoints.Base.rawValue + Endpoints.Version.rawValue + Endpoints.Subscriptions.rawValue
        requestGETURL(baseURL, parameters: parameters, success: { (response) -> Void in
            success(response)
        }) { (error) -> Void in
            failure(error)
        }
    }
    
    public func requestDiscounts(_ parameters: [String : AnyObject], success:@escaping (JSON) -> Void, failure:@escaping (NSError) -> Void) {
        let baseURL = site.url! + Endpoints.Base.rawValue + Endpoints.Version.rawValue + Endpoints.Discounts.rawValue
        requestGETURL(baseURL, parameters: parameters, success: { (response) -> Void in
            success(response)
        }) { (error) -> Void in
            failure(error)
        }
    }
    
    public func requestGETURL(_ strURL: String, parameters: Parameters, success:@escaping (JSON) -> Void, failure:@escaping (NSError) -> Void) {
        let auth : Parameters = ["key": site.key as AnyObject, "token": site.token as AnyObject]
        var passedParameters : Parameters = auth

        passedParameters.update(parameters)

        print("Request made to \(strURL)")

        let request = EDDNetworkManager.sharedInstance.request(strURL, method: .get, parameters: passedParameters)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                print(response.timeline)
                if response.result.isSuccess {
                    let resJSON = JSON(response.result.value!)
                    success(resJSON)
                }
                
                if response.result.isFailure {
                    let error: NSError = response.result.error! as NSError
                    failure(error)
                }
            }
        
        print(request)
        
        requests.append(request)
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
