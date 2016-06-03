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
        case Stats = "stats"
        case Sales = "sales"
        case Earnings = "earnings"
        case Commissions = "commissions"
        case Reviews = "reviews"
        case Subscriptions = "subscriptions"
    }
    
    private override init() {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        site = Site.defaultSite()
    }
    
    public func requestStats(parameters: [String : AnyObject], success:(JSON) -> Void, failure:(NSError) -> Void) {
        let baseURL = site.url! + Endpoints.Base.rawValue + Endpoints.Stats.rawValue
        requestGETURL(baseURL, parameters: parameters, success: { (response) -> Void in
            print(response)
        }) { (error) -> Void in
            print(error)
        }
    }
    
    public func requestSales(parameters: [String : AnyObject], success:(JSON) -> Void, failure:(NSError) -> Void) {
        let baseURL = site.url! + Endpoints.Base.rawValue + Endpoints.Sales.rawValue
        
        requestGETURL(baseURL, parameters: parameters, success: { (response) -> Void in
            print(response)
        }) { (error) -> Void in
            print(error)
        }
    }
    
    public func requestEarnings(parameters: [String : AnyObject], success:(JSON) -> Void, failure:(NSError) -> Void) {
        let baseURL = site.url! + Endpoints.Base.rawValue + Endpoints.Earnings.rawValue
        requestGETURL(baseURL, parameters: parameters, success: { (response) -> Void in
            print(response)
        }) { (error) -> Void in
            print(error)
        }
    }
    
    public func requestCommissions(parameters: [String : AnyObject], success:(JSON) -> Void, failure:(NSError) -> Void) {
        let baseURL = site.url! + Endpoints.Base.rawValue + Endpoints.Commissions.rawValue
        requestGETURL(baseURL, parameters: parameters, success: { (response) -> Void in
            print(response)
        }) { (error) -> Void in
            print(error)
        }
    }
    
    public func requestReviews(parameters: [String : AnyObject], success:(JSON) -> Void, failure:(NSError) -> Void) {
        let baseURL = site.url! + Endpoints.Base.rawValue + Endpoints.Reviews.rawValue
        requestGETURL(baseURL, parameters: parameters, success: { (response) -> Void in
            print(response)
        }) { (error) -> Void in
            print(error)
        }
    }
    
    public func requestGETURL(strURL: String, parameters: [String: AnyObject], success:(JSON) -> Void, failure:(NSError) -> Void) {
        let auth : [String : AnyObject] = ["key": site.key, "token": site.token]
        var passedParameters : [String: AnyObject] = auth

        passedParameters.update(parameters)
        
        Alamofire.request(.GET, strURL, parameters: auth)
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
        let baseURL = site.url! + Endpoints.Base.rawValue + Endpoints.Subscriptions.rawValue
        var ret: Bool = false

        requestGETURL(baseURL, parameters: [:], success: { (response) -> Void in
            print(response)
            ret = true
        }) { (error) -> Void in
            print(error)
        }
        
        return ret
    }

}