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
import SwiftyJSON

public final class Sale: ManagedObject {

    // Attributes
    @NSManaged private var createdAt: NSDate
    @NSManaged public private(set) var date: NSDate
    @NSManaged public private(set) var email: String
    @NSManaged public private(set) var fees: [String: AnyObject]?
    @NSManaged public private(set) var gateway: String
    @NSManaged public private(set) var key: String
    @NSManaged public private(set) var sid: Int64
    @NSManaged public private(set) var subtotal: NSNumber
    @NSManaged public private(set) var tax: NSNumber
    @NSManaged public private(set) var total: NSNumber
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
    
    public static func insertIntoContext(moc: NSManagedObjectContext, date: NSDate, email: String, fees: [String: AnyObject]?, gateway: String, key: String, sid: Int64, subtotal: Double, tax: Double, total: Double, transactionId: String, products: [JSON]) -> Sale {
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
        sale.site = Site.fetchRecordForActiveSite(inContext: moc)
        
        for product in products {
            let items = sale.mutableSetValueForKey(Sale.Keys.Products.rawValue)
            
        }
    
        return sale
    }
    
    public static func predicateForTransactionId(transactionId: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", Sale.Keys.TransactionID.rawValue, transactionId)
    }
    
    public static func predicateForId(id: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", Sale.Keys.ID.rawValue, id)
    }
    
    public static func saleForTransactionId(transactionId: String) -> Sale? {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        let sale = Sale.fetchInContext(managedObjectContext) { (request) in
            request.predicate = self.predicateForTransactionId(transactionId)
            request.fetchLimit = 1
        }
        
        if sale.count > 0 {
            return sale[0]
        } else {
            return nil
        }
    }
    
    public static func saleForId(Id: String) -> Sale? {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        let sale = Sale.fetchInContext(managedObjectContext) { (request) in
            request.predicate = self.predicateForId(Id)
            request.fetchLimit = 1
        }
        
        if sale.count > 0 {
            return sale[0]
        } else {
            return nil
        }
    }
    
    public static func defaultFetchRequest() -> NSFetchRequest {
        let request = NSFetchRequest(entityName: "Sale")
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        return request
    }
    
    public static func fetchMostRecentSale() -> Sale {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        let sale = Sale.fetchSingleObjectInContext(managedObjectContext) { request in
            request.returnsObjectsAsFaults = false
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            request.fetchLimit = 1
        }
        
        return sale!
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

extension Sale: KeyCodable {

    public enum Keys: String {
        case CreatedAt = "createdAt"
        case Date = "date"
        case Email = "email"
        case Fees = "fees"
        case Gateway = "gateway"
        case Key = "key"
        case ID = "sid"
        case Subtotal = "subtotal"
        case Tax = "tax"
        case Total = "total"
        case TransactionID = "transactionId"
        case Products = "products"
    }

}
