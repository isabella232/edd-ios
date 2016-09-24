//
//  Product.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 17/07/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData

public final class Product: ManagedObject {

    // Attributes
    @NSManaged public private(set) var content: String
    @NSManaged private var createdAt: NSDate
    @NSManaged public private(set) var createdDate: NSDate
    @NSManaged public private(set) var files: NSData?
    @NSManaged public private(set) var hasVariablePricing: NSNumber
    @NSManaged public private(set) var link: String
    @NSManaged public private(set) var modifiedDate: NSDate
    @NSManaged public private(set) var notes: String?
    @NSManaged public private(set) var pid: Int64
    @NSManaged public private(set) var pricing: NSData
    @NSManaged public private(set) var stats: NSData?
    @NSManaged public private(set) var status: String
    @NSManaged public private(set) var thumbnail: String?
    @NSManaged public private(set) var title: String
    
    // Relationships
    @NSManaged private(set) var subscriptions: Set<Subscription>
    @NSManaged public private(set) var site: Site
    @NSManaged private(set) var sales: Set<Sale>
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        createdAt = NSDate()
    }
    
    public static func predicateForId(productId: Int64) -> NSPredicate {
        return NSPredicate(format: "%K == %lld", Product.Keys.ID.rawValue, productId)
    }
    
    public static func insertIntoContext(moc: NSManagedObjectContext, content: String, createdDate: NSDate, files: NSData?, hasVariablePricing: NSNumber, link: String, modifiedDate: NSDate, notes: String?, pid: Int64, pricing: NSData, stats: NSData?, status: String, thumbnail: String, title: String) -> Product {
        let product: Product = moc.insertObject()
        product.content = content
        product.createdDate = createdDate
        product.files = files
        product.hasVariablePricing = hasVariablePricing
        product.link = link
        product.modifiedDate = modifiedDate
        product.notes = notes
        product.pid = pid
        product.pricing = pricing
        product.stats = stats
        product.status = status
        product.thumbnail = thumbnail
        product.title = title
        product.site = Site.fetchRecordForActiveSite(inContext: moc)
        
        return product
    }
    
    public static func productForId(productId: Int64) -> Product? {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        let product = Product.fetchInContext(managedObjectContext) { (request) in
            request.predicate = self.predicateForId(productId)
            request.fetchLimit = 1
        }
        
        if product.count > 0 {
            return product[0]
        } else {
            return nil
        }
    }
    
}

extension Product: ManagedObjectType {
    
    public static var entityName: String {
        return "Product"
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
    
}

extension Product: KeyCodable {
    
    public enum Keys: String {
        case Content = "content"
        case CreatedAt = "createdAt"
        case CreatedDate = "createdDate"
        case Files = "files"
        case HasVariablePricing = "hasVariablePricing"
        case Link = "link"
        case ModifiedDate = "modifiedDate"
        case Notes = "notes"
        case ID = "pid"
        case Pricing = "pricing"
        case Stats = "stats"
        case Status = "status"
        case Thumbnmail = "thumbnail"
        case Title = "title"
    }
    
}
