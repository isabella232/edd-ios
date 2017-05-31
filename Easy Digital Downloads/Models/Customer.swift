//
//  Customer.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 17/07/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData

public final class Customer: ManagedObject {

    // Attributes
    @NSManaged fileprivate var createdAt: Date
    @NSManaged public fileprivate(set) var displayName: String
    @NSManaged public fileprivate(set) var email: String
    @NSManaged public fileprivate(set) var firstName: String
    @NSManaged public fileprivate(set) var lastName: String
    @NSManaged public fileprivate(set) var totalDownloads: Int64
    @NSManaged public fileprivate(set) var totalPurchases: Int64
    @NSManaged public fileprivate(set) var totalSpent: Double
    @NSManaged public fileprivate(set) var uid: Int64
    @NSManaged public fileprivate(set) var username: String
    @NSManaged public fileprivate(set) var dateCreated: Date
    
    // Relationships
    @NSManaged fileprivate(set) var subscriptions: Set<Subscription>
    @NSManaged fileprivate(set) var sales: Set<Sale>
    @NSManaged public fileprivate(set) var site: Site
        
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        createdAt = Date()
    }
    
    public static func predicateForId(_ customerId: Int64) -> NSPredicate {
        return NSPredicate(format: "%K == %lld", Customer.Keys.ID.rawValue, customerId)
    }
    
    public static func predicateForUsername(_ username: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", Customer.Keys.Username.rawValue, username)
    }
    
    @discardableResult
    public static func insertIntoContext(_ moc: NSManagedObjectContext, displayName: String, email: String, firstName: String, lastName: String, totalDownloads: Int64, totalPurchases: Int64, totalSpent: Double, uid: Int64, username: String, dateCreated: Date) -> Customer {
        let customer: Customer = moc.insertObject()
        customer.displayName = displayName
        customer.email = email
        customer.firstName = firstName
        customer.lastName = lastName
        customer.totalDownloads = totalDownloads
        customer.totalPurchases = totalPurchases
        customer.totalSpent = totalSpent
        customer.uid = uid
        customer.username = username
        customer.dateCreated = dateCreated
        customer.site = Site.fetchRecordForActiveSite(inContext: moc)

        return customer
    }
    
    @discardableResult
    public static func objectForData(_ moc: NSManagedObjectContext, displayName: String, email: String, firstName: String, lastName: String, totalDownloads: Int64, totalPurchases: Int64, totalSpent: Double, uid: Int64, username: String, dateCreated: Date) -> Customer {
        let entity = NSEntityDescription.entity(forEntityName: "Customer", in: moc)
        let object = NSManagedObject(entity: entity!, insertInto: nil) as! Customer

        object.displayName = displayName
        object.email = email
        object.firstName = firstName
        object.lastName = lastName
        object.totalDownloads = totalDownloads
        object.totalPurchases = totalPurchases
        object.totalSpent = totalSpent
        object.uid = uid
        object.username = username
        object.dateCreated = dateCreated
        
        return object
    }
    
    public static func customerForId(_ customerId: Int64) -> Customer? {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        let customer = Customer.fetchInContext(managedObjectContext) { (request) in
            request.predicate = self.predicateForId(customerId)
            request.fetchLimit = 1
        }
        
        if customer.count > 0 {
            return customer[0]
        } else {
            return nil
        }
    }

}

extension Customer: ManagedObjectType {
    
    public static var entityName: String {
        return "Customer"
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
        request.sortDescriptors = [NSSortDescriptor(key: Customer.Keys.DateCreated.rawValue, ascending: false)]
        return request
    }
    
}

extension Customer: KeyCodable {
    
    public enum Keys: String {
        case CreatedAt = "createdAt"
        case DateCreated = "dateCreated"
        case DisplayName = "displayName"
        case Email = "email"
        case FirstName = "firstName"
        case LastName = "lastName"
        case TotalDownloads = "totalDownloads"
        case TotalPurchases = "totalPurchases"
        case TotalSpent = "totalSpent"
        case ID = "uid"
        case Username = "username"
    }
    
}
