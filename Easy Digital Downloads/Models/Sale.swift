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
    @NSManaged fileprivate var createdAt: Date
    @NSManaged public fileprivate(set) var customer: String
    @NSManaged public fileprivate(set) var date: Date
    @NSManaged public fileprivate(set) var discounts: [String: AnyObject]?
    @NSManaged public fileprivate(set) var email: String
    @NSManaged public fileprivate(set) var fees: Data?
    @NSManaged public fileprivate(set) var gateway: String
    @NSManaged public fileprivate(set) var key: String
    @NSManaged public fileprivate(set) var licenses: Data?
    @NSManaged public fileprivate(set) var products: Data
    @NSManaged public fileprivate(set) var sid: Int64
    @NSManaged public fileprivate(set) var subtotal: NSNumber
    @NSManaged public fileprivate(set) var tax: NSNumber
    @NSManaged public fileprivate(set) var total: NSNumber
    @NSManaged public fileprivate(set) var transactionId: String
    
    // Relationships
    @NSManaged public fileprivate(set) var site: Site
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        createdAt = Date()
    }
    
    public static func insertIntoContext(_ moc: NSManagedObjectContext, customer: String, date: Date, email: String, fees: [AnyObject]?, gateway: String, key: String, sid: Int64, subtotal: Double, tax: Double, total: Double, transactionId: String, products: [AnyObject], discounts: [String: AnyObject]?, licenses: [AnyObject]?) -> Sale {
        let sale: Sale = moc.insertObject()
        sale.customer = customer
        sale.date = date
        sale.email = email
        sale.gateway = gateway
        sale.key = key
        sale.sid = sid
        sale.subtotal = NSNumber(value: subtotal)
        sale.tax = NSNumber(value: tax)
        sale.total = NSNumber(value: total)
        sale.transactionId = transactionId
        sale.site = Site.fetchRecordForActiveSite(inContext: moc)
        sale.products = NSKeyedArchiver.archivedData(withRootObject: products)
        sale.discounts = discounts
        
        if licenses != nil {
            sale.licenses = NSKeyedArchiver.archivedData(withRootObject: licenses!)
        } else {
            sale.licenses = nil
        }
        
        if let feesObject = fees {
            sale.fees = NSKeyedArchiver.archivedData(withRootObject: feesObject)
        } else {
            sale.fees = nil
        }
        
        return sale
    }
    
    public static func objectForData(_ moc: NSManagedObjectContext, customer: String, date: Date, email: String, fees: [AnyObject]?, gateway: String, key: String, sid: Int64, subtotal: Double, tax: Double, total: Double, transactionId: String, products: [AnyObject], discounts: [String: AnyObject]?, licenses: [AnyObject]?) -> Sale {
        let entity = NSEntityDescription.entity(forEntityName: "Sale", in: moc)
        let object = NSManagedObject(entity: entity!, insertInto: nil) as! Sale
        
        object.customer = customer
        object.date = date
        object.email = email
        object.gateway = gateway
        object.key = key
        object.sid = sid
        object.subtotal = NSNumber(value: subtotal)
        object.tax = NSNumber(value: tax)
        object.total = NSNumber(value: total)
        object.transactionId = transactionId
        object.products = NSKeyedArchiver.archivedData(withRootObject: products)
        object.discounts = discounts
        
        if licenses != nil {
            object.licenses = NSKeyedArchiver.archivedData(withRootObject: licenses!)
        } else {
            object.licenses = nil
        }
        
        if let feesObject = fees {
            object.fees = NSKeyedArchiver.archivedData(withRootObject: feesObject)
        } else {
            object.fees = nil
        }
        
        return object
    }
    
    public static func predicateForTransactionId(_ transactionId: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", Sale.Keys.TransactionID.rawValue, transactionId)
    }
    
    public static func predicateForId(_ id: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", Sale.Keys.ID.rawValue, id)
    }
    
    public static func saleForTransactionId(_ transactionId: String) -> Sale? {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
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
    
    public static func saleForId(_ Id: String) -> Sale? {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
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
    
    public static func defaultFetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Sale")
        request.returnsObjectsAsFaults = false
        request.predicate = defaultPredicate
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        return request
    }
    
    public static func fetchMostRecentSale() -> Sale {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
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
