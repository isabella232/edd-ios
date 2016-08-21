//
//  Sale.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 17/07/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import Foundation
import UIKit
import CoreData

public final class Sale: ManagedObject {

    // Attributes
    @NSManaged private var createdAt: NSDate
    @NSManaged public private(set) var date: NSDate
    @NSManaged public private(set) var email: String
    @NSManaged public private(set) var fees: NSDictionary
    @NSManaged public private(set) var gateway: String
    @NSManaged public private(set) var key: String
    @NSManaged public private(set) var sid: Int16
    @NSManaged public private(set) var subtotal: Double
    @NSManaged public private(set) var tax: Double
    @NSManaged public private(set) var total: Double
    @NSManaged public private(set) var transactionId: String
    
    // Relationships
    @NSManaged public private(set) var site: Site
    @NSManaged private(set) var products: Set<Product>
    @NSManaged private(set) var discounts: Set<Discount>
    @NSManaged public private(set) var customer: Customer
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        createdAt = NSDate()
    }
    
    public static func insertIntoContext(moc: NSManagedObjectContext, date: NSDate, email: String, fees: NSDictionary, gateway: String, key: String, sid: Int16, subtotal: Double, tax: Double, total: Double, transactionId: String) -> Sale {
        let sale: Sale = moc.insertObject()
        sale.date = date
        sale.email = email
        sale.fees = fees
        sale.gateway = gateway
        sale.key = key
        sale.sid = sid
        sale.subtotal = subtotal
        sale.tax = tax
        sale.total = total
        sale.transactionId = transactionId
        return sale
    }
    
    public static func predicateForTransactionId(transactionId: String) -> NSPredicate {
        return NSPredicate(format: "transactionId == %@", transactionId)
    }
    
    public static func saleForTransactionId(transactionId: String) -> Sale {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        let sale = Sale.fetchSingleObjectInContext(managedObjectContext) { request in
            request.predicate = self.predicateForTransactionId(transactionId)
            request.fetchLimit = 1
        }
    }
    
}

extension Sale: ManagedObjectType {
    
    public static var entityName: String {
        return "Sale"
    }
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: CreatedTimestampKey, ascending: false)]
    }
    
    public static var defaultPredicate: NSPredicate {
        return NSPredicate()
    }
    
}
