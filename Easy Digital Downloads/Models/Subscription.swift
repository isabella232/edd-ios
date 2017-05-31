//
//  Subscription.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 17/07/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData

public final class Subscription: ManagedObject {

    // Attributes
    @NSManaged fileprivate var createdAt: Date
    @NSManaged public fileprivate(set) var billTimes: Int64
    @NSManaged public fileprivate(set) var customer: [String: AnyObject]
    @NSManaged public fileprivate(set) var created: Date
    @NSManaged public fileprivate(set) var expiration: Date
    @NSManaged public fileprivate(set) var gateway: String
    @NSManaged public fileprivate(set) var initialAmount: Double
    @NSManaged public fileprivate(set) var notes: [AnyObject]?
    @NSManaged public fileprivate(set) var parentPaymentID: Int64
    @NSManaged public fileprivate(set) var period: String
    @NSManaged public fileprivate(set) var productID: Int64
    @NSManaged public fileprivate(set) var profileID: String
    @NSManaged public fileprivate(set) var recurringAmount: Double
    @NSManaged public fileprivate(set) var sid: Int64
    @NSManaged public fileprivate(set) var status: String
    @NSManaged public fileprivate(set) var transactionId: String?
    @NSManaged public fileprivate(set) var payments: [AnyObject]?
    
    // Relationships
    @NSManaged public fileprivate(set) var site: Site
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        createdAt = Date()
    }
    
    public static func predicateForId(_ subscriptionId: Int64) -> NSPredicate {
        return NSPredicate(format: "%K == %lld", Subscription.Keys.ID.rawValue, subscriptionId)
    }
    
    @discardableResult
    public static func insertIntoContext(_ moc: NSManagedObjectContext, billTimes: Int64, created: Date, customer: [String: AnyObject], expiration: Date, gateway: String, initialAmount: Double, notes: [AnyObject]?, parentPaymentID: Int64, period: String, productID: Int64, profileID: String, recurringAmount: Double, sid: Int64, status: String, transactionId: String?, payments: [AnyObject]?) -> Subscription {
        let subscription: Subscription = moc.insertObject()
        subscription.billTimes = billTimes
        subscription.created = created
        subscription.customer = customer
        subscription.expiration = expiration
        subscription.gateway = gateway
        subscription.initialAmount = initialAmount
        subscription.notes = notes
        subscription.parentPaymentID = parentPaymentID
        subscription.period = period
        subscription.productID = productID
        subscription.profileID = profileID
        subscription.recurringAmount = recurringAmount
        subscription.sid = sid
        subscription.status = status
        subscription.transactionId = transactionId
        subscription.payments = payments
        subscription.site = Site.fetchRecordForActiveSite(inContext: moc)
        
        return subscription
    }
    
    public static func subscriptionForId(_ subscriptionId: Int64) -> Subscription? {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        let subscription = Subscription.fetchInContext(managedObjectContext) { (request) in
            request.predicate = self.predicateForId(subscriptionId)
            request.fetchLimit = 1
        }
        
        if subscription.count > 0 {
            return subscription[0]
        } else {
            return nil
        }
    }
    
    public static func fetchRecordForId(_ subscriptionId: Int64, inContext moc: NSManagedObjectContext) -> Subscription? {
        let subscription = Subscription.fetchSingleObjectInContext(moc) { request in
            request.predicate = predicateForId(subscriptionId)
            request.fetchLimit = 1
        }
        return subscription ?? nil
    }
    
}

extension Subscription: ManagedObjectType {
    
    public static var entityName: String {
        return "Subscription"
    }
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: CreatedTimestampKey, ascending: false)]
    }
    
    public static var defaultPredicate: NSPredicate {
        return NSPredicate(format: "site.uid == %@", Site.activeSite().uid!)
    }
    
    public static func defaultFetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.fetchLimit = 20
        request.predicate = defaultPredicate
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: Subscription.Keys.Created.rawValue, ascending: false)]
        return request
    }
    
}

extension Subscription: KeyCodable {
    
    public enum Keys: String {
        case BillTimes = "billTimes"
        case Created = "created"
        case CreatedAt = "createdAt"
        case Customer = "customer"
        case Expiration = "expiration"
        case Gateway = "gateway"
        case InitialAmount = "initialAmount"
        case Notes = "notes"
        case ParentPaymentId = "paymentPaymentID"
        case Period = "period"
        case ProductID = "productID"
        case ProfileID = "profileID"
        case RecurringAmount = "recurringAmount"
        case ID = "sid"
        case Status = "status"
    }
    
}
