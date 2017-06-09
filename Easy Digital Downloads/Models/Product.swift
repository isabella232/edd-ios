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
    @NSManaged public fileprivate(set) var content: String
    @NSManaged fileprivate var createdAt: Date
    @NSManaged public fileprivate(set) var createdDate: Date
    @NSManaged public fileprivate(set) var files: Data?
    @NSManaged public fileprivate(set) var hasVariablePricing: NSNumber
    @NSManaged public fileprivate(set) var link: String
    @NSManaged public fileprivate(set) var licensing: [String: AnyObject]?
    @NSManaged public fileprivate(set) var modifiedDate: Date
    @NSManaged public fileprivate(set) var notes: String?
    @NSManaged public fileprivate(set) var pid: Int64
    @NSManaged public fileprivate(set) var pricing: Data
    @NSManaged public fileprivate(set) var stats: Data?
    @NSManaged public fileprivate(set) var status: String
    @NSManaged public fileprivate(set) var thumbnail: String?
    @NSManaged public fileprivate(set) var title: String
    
    // Relationships
    @NSManaged fileprivate(set) var subscriptions: Set<Subscription>
    @NSManaged public fileprivate(set) var site: Site
    @NSManaged fileprivate(set) var sales: Set<Sale>
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        createdAt = Date()
    }
    
    public static func predicateForId(_ productId: Int64) -> NSPredicate {
        return NSPredicate(format: "%K == %lld", Product.Keys.ID.rawValue, productId)
    }
    
    @discardableResult
    public static func insertIntoContext(_ moc: NSManagedObjectContext, content: String, createdDate: Date, files: Data?, hasVariablePricing: NSNumber, link: String, modifiedDate: Date, notes: String?, pid: Int64, pricing: Data, stats: Data?, status: String, thumbnail: String?, title: String, licensing: [String: AnyObject]?) -> Product {
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
        product.licensing = licensing ?? nil
        
        return product
    }
    
    public static func objectForData(_ moc: NSManagedObjectContext, content: String, createdDate: Date, files: Data?, hasVariablePricing: NSNumber, link: String, modifiedDate: Date, notes: String?, pid: Int64, pricing: Data, stats: Data?, status: String, thumbnail: String?, title: String, licensing: [String: AnyObject]?) -> Product {
        let entity = NSEntityDescription.entity(forEntityName: "Product", in: moc)
        let object = NSManagedObject(entity: entity!, insertInto: nil) as! Product

        object.content = content
        object.createdDate = createdDate
        object.files = files
        object.hasVariablePricing = hasVariablePricing
        object.link = link
        object.modifiedDate = modifiedDate
        object.notes = notes
        object.pid = pid
        object.pricing = pricing
        object.stats = stats
        object.status = status
        object.thumbnail = thumbnail
        object.title = title
        object.licensing = licensing ?? nil
        return object
    }
    
    public static func productForId(_ productId: Int64) -> Product? {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
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
    
    public static func fetchRecordForId(_ productId: Int64, inContext moc: NSManagedObjectContext) -> Product? {
        let product = Product.fetchSingleObjectInContext(moc) { request in
            request.predicate = predicateForId(productId)
            request.fetchLimit = 1
        }
        return product ?? nil
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
        return NSPredicate(format: "(site.uid == %@) AND (status == %@)", Site.activeSite().uid!, "publish")
    }
    
    public static func defaultFetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
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
