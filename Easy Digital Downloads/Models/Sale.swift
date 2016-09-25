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
    @NSManaged public private(set) var customer: String
    @NSManaged public private(set) var date: NSDate
    @NSManaged public private(set) var discounts: [String: AnyObject]?
    @NSManaged public private(set) var email: String
    @NSManaged public private(set) var fees: NSData?
    @NSManaged public private(set) var gateway: String
    @NSManaged public private(set) var key: String
    @NSManaged public private(set) var licenses: NSData?
    @NSManaged public private(set) var products: NSData
    @NSManaged public private(set) var sid: Int64
    @NSManaged public private(set) var subtotal: NSNumber
    @NSManaged public private(set) var tax: NSNumber
    @NSManaged public private(set) var total: NSNumber
    @NSManaged public private(set) var transactionId: String
    
    // Relationships
    @NSManaged public private(set) var site: Site
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        createdAt = NSDate()
    }
    
    public static func insertIntoContext(moc: NSManagedObjectContext, customer: String, date: NSDate, email: String, fees: [AnyObject]?, gateway: String, key: String, sid: Int64, subtotal: Double, tax: Double, total: Double, transactionId: String, products: [AnyObject], discounts: [String: AnyObject]?, licenses: [AnyObject]?) -> Sale {
        let sale: Sale = moc.insertObject()
        sale.customer = customer
        sale.date = date
        sale.email = email
        sale.gateway = gateway
        sale.key = key
        sale.sid = sid
        sale.subtotal = subtotal
        sale.tax = tax
        sale.total = total
        sale.transactionId = transactionId
        sale.site = Site.fetchRecordForActiveSite(inContext: moc)
        sale.products = NSKeyedArchiver.archivedDataWithRootObject(products)
        sale.discounts = discounts
        
        if licenses != nil {
            sale.licenses = NSKeyedArchiver.archivedDataWithRootObject(licenses!)
        } else {
            sale.licenses = nil
        }
        
        if let feesObject = fees {
            sale.fees = NSKeyedArchiver.archivedDataWithRootObject(feesObject)
        } else {
            sale.fees = nil
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
        request.predicate = defaultPredicate
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
        return NSPredicate(format: "site.uid == %@", Site.activeSite().uid!)
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
