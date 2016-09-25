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
    @NSManaged private var createdAt: NSDate
    @NSManaged public private(set) var billTimes: Int64
    @NSManaged public private(set) var customer: [String: AnyObject]
    @NSManaged public private(set) var created: NSDate
    @NSManaged public private(set) var expiration: NSDate
    @NSManaged public private(set) var gateway: String
    @NSManaged public private(set) var initialAmount: Double
    @NSManaged public private(set) var notes: String?
    @NSManaged public private(set) var parentPaymentID: Int64
    @NSManaged public private(set) var period: String
    @NSManaged public private(set) var productID: Int64
    @NSManaged public private(set) var profileID: String
    @NSManaged public private(set) var recurringAmount: Double
    @NSManaged public private(set) var sid: Int64
    @NSManaged public private(set) var status: String
    
    // Relationships
    @NSManaged public private(set) var site: Site
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        createdAt = NSDate()
    }
    
    public static func predicateForId(subscriptionId: Int64) -> NSPredicate {
        return NSPredicate(format: "%K == %lld", Subscription.Keys.ID.rawValue, subscriptionId)
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
    
    public static func defaultFetchRequest() -> NSFetchRequest {
        let request = NSFetchRequest(entityName: self.entityName)
        request.fetchLimit = 20
        request.predicate = defaultPredicate
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: Product.Keys.CreatedDate.rawValue, ascending: false)]
        return request
    }
    
    public static func insertIntoContext(moc: NSManagedObjectContext, billTimes: Int64, created: NSDate, customer: [String: AnyObject], expiration: NSDate, gateway: String, initialAmount: Double, notes: String?, parentPaymentID: Int64, period: String, productID: Int64, profileID: String, recurringAmount: Double, sid: Int64, status: String) -> Subscription {
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
        subscription.site = Site.fetchRecordForActiveSite(inContext: moc)
        
        return subscription
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
