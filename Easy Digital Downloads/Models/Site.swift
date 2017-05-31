//
//  Site.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 29/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import SSKeychain

let CreatedTimestampKey = "createdAt"

enum SiteType: Int16 {
    case standard = 0
    case store = 1
    case commission = 2
    case standardStore = 3
    case standardCommission = 4
}

private let sharedNumberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = Site.activeSite().currency!
    return formatter
}()

private let sharedDefaults: UserDefaults = {
   return UserDefaults(suiteName: "group.easydigitaldownloads.EDDSalesTracker")!
}()

public final class Site: ManagedObject {
    
    // Attributes
    @NSManaged public fileprivate(set) var name: String?
    @NSManaged public fileprivate(set) var uid: String?
    @NSManaged public fileprivate(set) var url: String?
    @NSManaged public fileprivate(set) var currency: String?
    @NSManaged public fileprivate(set) var hasCommissions: NSNumber?
    @NSManaged public fileprivate(set) var hasFES: NSNumber?
    @NSManaged public fileprivate(set) var hasRecurring: NSNumber?
    @NSManaged public fileprivate(set) var hasReviews: NSNumber?
    @NSManaged public fileprivate(set) var hasLicensing: NSNumber?
    @NSManaged public fileprivate(set) var createdAt: Date?
    @NSManaged public fileprivate(set) var permissions: Data?
    @NSManaged public fileprivate(set) var dashboardOrder: Data?
    
    // Relationships
    @NSManaged fileprivate(set) var commissions: Set<Commission>
    @NSManaged fileprivate(set) var customers: Set<Customer>
    @NSManaged fileprivate(set) var discounts: Set<Discount>
    @NSManaged fileprivate(set) var products: Set<Product>
    @NSManaged fileprivate(set) var sales: Set<Sale>
    @NSManaged fileprivate(set) var subscriptions: Set<Subscription>

    var key: String = ""
    var token: String = ""
        
    var isCommissionActive: Bool {
        get {
            return Bool(hasCommissions!)
        }
    }
    
    var isFESActive: Bool {
        get {
            return Bool(hasFES!)
        }
    }
    
    var isRecurringActive: Bool {
        get {
            return Bool(hasRecurring!)
        }
    }
    
    var isReviewsActive: Bool {
        get {
            return Bool(hasReviews!)
        }
    }
    
    public static func insertIntoContext(_ moc: NSManagedObjectContext, uid: String, name: String, url: String, currency: String, hasCommissions: Bool, hasFES: Bool, hasRecurring: Bool, hasReviews: Bool, hasLicensing: Bool, permissions: Data, dashboardOrder: Data) -> Site {
        let site: Site = moc.insertObject()
        site.uid = uid
        site.name = name
        site.url = url
        site.currency = currency
        site.createdAt = Date()
        site.hasCommissions = hasCommissions as NSNumber
        site.hasFES = hasFES as NSNumber
        site.hasRecurring = hasRecurring as NSNumber
        site.hasReviews = hasReviews as NSNumber
        site.hasLicensing = hasLicensing as NSNumber
        site.permissions = permissions
        site.dashboardOrder = dashboardOrder
        return site
    }
    
    public static func predicateForDefaultSite() -> NSPredicate {
        guard let defaultSiteId = sharedDefaults.string(forKey: "defaultSite") else {
            fatalError("No default site set")
        }
        return NSPredicate(format: "uid == %@", defaultSiteId)
    }
    
    public static func predicateForActiveSite() -> NSPredicate {
        guard let activeSiteId = sharedDefaults.string(forKey: "activeSite") else {
            fatalError("No active site set")
        }
        return NSPredicate(format: "uid == %@", activeSiteId)
    }
    
    public static func defaultSite() -> Site {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        let site = Site.fetchSingleObjectInContext(managedObjectContext) { request in
            request.predicate = self.predicateForDefaultSite()
            request.fetchLimit = 1
        }

        let auth = SSKeychain.accounts(forService: site!.uid)
        let data = auth?[0] as NSDictionary
        let acct = data.object(forKey: "acct") as! String
        let password = SSKeychain.password(forService: site!.uid, account: acct)
        
        site!.key = acct
        site!.token = password!

        return site!
    }
    
    public static func hasActiveSite() -> Bool? {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext

        let site = Site.fetchSingleObjectInContext(managedObjectContext) { request in
            request.predicate = self.predicateForActiveSite()
            request.fetchLimit = 1
        }
        
        if site == nil {
            return nil
        } else {
            return true
        }
    }
    
    public static func activeSite() -> Site {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        let site = Site.fetchSingleObjectInContext(managedObjectContext) { request in
            request.predicate = self.predicateForActiveSite()
            request.fetchLimit = 1
        }
        
        guard let site_ = site else {
            AppDelegate.sharedInstance.handleNoActiveSite()
            return Site()
        }
        
        let auth = SSKeychain.accounts(forService: site_.uid)
        let data = auth?[0] as! NSDictionary
        let acct = data.object(forKey: "acct") as! String
        let password = SSKeychain.password(forService: site_.uid, account: acct)
        
        site_.key = acct
        site_.token = password!
        
        return site_
    }
    
    public static func decodePermissionsForActiveSite() -> NSDictionary {
        let site = Site.activeSite()
        let permissions: NSDictionary = NSKeyedUnarchiver.unarchiveObject(with: site.permissions!)! as! NSDictionary
        return permissions
    }
    
    public static func getDashboardOrderForActiveSite() -> [Int] {
        let site = Site.activeSite()
        let dashboardOrder: [Int] = NSKeyedUnarchiver.unarchiveObject(with: site.dashboardOrder!)! as! [Int]
        return dashboardOrder
    }
    
    public static func fetchRecordForActiveSite(inContext moc: NSManagedObjectContext) -> Site {
        let site = Site.fetchSingleObjectInContext(moc) { request in
            request.predicate = self.predicateForActiveSite()
            request.fetchLimit = 1
        }
        return site!
    }
    
    public static func currencyFormat(_ number: NSNumber) -> String {
        return sharedNumberFormatter.string(from: number)!
    }
    
    public static func fetchSalesForActiveSite(inContext moc: NSManagedObjectContext) -> Set<Sale> {
        let site = Site.fetchRecordForActiveSite(inContext: moc)
        return site.sales
    }
    
    public static func fetchSubscriptionsForActiveSite(inContext moc: NSManagedObjectContext) -> Set<Subscription> {
        let site = Site.fetchRecordForActiveSite(inContext: moc)
        return site.subscriptions
    }
    
    public static func fetchProductsForActiveSite(inContext moc: NSManagedObjectContext) -> Set<Product> {
        let site = Site.fetchRecordForActiveSite(inContext: moc)
        return site.products
    }
    
    public static func fetchDiscountsForActiveSite(inContext moc: NSManagedObjectContext) -> Set<Discount> {
        let site = Site.fetchRecordForActiveSite(inContext: moc)
        return site.discounts
    }
    
    public static func fetchCustomersForActiveSite(inContext moc: NSManagedObjectContext) -> Set<Customer> {
        let site = Site.fetchRecordForActiveSite(inContext: moc)
        return site.customers
    }
    
    public static func fetchCommissionsForActiveSite(inContext moc: NSManagedObjectContext) -> Set<Commission> {
        let site = Site.fetchRecordForActiveSite(inContext: moc)
        return site.commissions
        
    }
    
    public static func fetchAll(inContext moc: NSManagedObjectContext) -> [Site]? {
        let results = Site.fetchInContext(moc)
        return results
    }
    
    public static func hasPermissionToViewReports() -> Bool {
        guard let data = Site.activeSite().permissions else {
            return false
        }
        
        let permissions = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: AnyObject]
        
        if permissions?["view_shop_reports"] !== nil {
            return true
        } else {
            return false
        }
    }
    
    public static func hasPermissionToViewSensitiveData() -> Bool {
        guard let data = Site.activeSite().permissions else {
            return false
        }
        
        let permissions = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: AnyObject]
        
        if permissions?["view_shop_sensitive_data"] !== nil {
            return true
        } else {
            return false
        }
    }
    
    public static func hasPermissionToManageDiscounts() -> Bool {
        guard let data = Site.activeSite().permissions else {
            return false
        }
        
        let permissions = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: AnyObject]
        
        if permissions?["manage_shop_discounts"] !== nil {
            return true
        } else {
            return false
        }
    }
    
    public static func deleteSite(_ uid: String) {
        let productRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Product")
        productRequest.predicate = Product.defaultPredicate
        productRequest.returnsObjectsAsFaults = false
        let productDeleteRequest = NSBatchDeleteRequest(fetchRequest: productRequest)
        
        let customerRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Customer")
        customerRequest.predicate = Customer.defaultPredicate
        customerRequest.returnsObjectsAsFaults = false
        let customerDeleteRequest = NSBatchDeleteRequest(fetchRequest: customerRequest)
        
        let siteRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Site")
        siteRequest.predicate = NSPredicate(format: "uid == %@", uid)
        siteRequest.returnsObjectsAsFaults = false
        let siteDeleteRequest = NSBatchDeleteRequest(fetchRequest: siteRequest)
        
        do {
            try AppDelegate.sharedInstance.managedObjectContext.execute(productDeleteRequest)
            try AppDelegate.sharedInstance.managedObjectContext.execute(customerDeleteRequest)
            try AppDelegate.sharedInstance.managedObjectContext.execute(siteDeleteRequest)
        } catch let error as NSError {
            print(error)
        }
    }
    
    public static func refreshActiveSite() -> Site {
        return Site.fetchSingleObjectInContext(AppDelegate.sharedInstance.managedObjectContext) { request in
            request.fetchLimit = 1
        }!
    }

}

extension Site: ManagedObjectType {
    
    public static var entityName: String {
        return "Site"
    }
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: CreatedTimestampKey, ascending: false)]
    }
    
    public static var defaultPredicate: NSPredicate {
        return NSPredicate()
    }
    
}
