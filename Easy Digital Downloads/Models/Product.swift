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
    @NSManaged public private(set) var files: NSDictionary
    @NSManaged public private(set) var hasVariablePricing: NSNumber
    @NSManaged public private(set) var link: String
    @NSManaged public private(set) var modifiedDate: NSDate
    @NSManaged public private(set) var notes: String
    @NSManaged public private(set) var pid: Int16
    @NSManaged public private(set) var pricing: NSDictionary
    @NSManaged public private(set) var stats: NSDictionary
    @NSManaged public private(set) var status: String
    @NSManaged public private(set) var thumbnail: String
    @NSManaged public private(set) var title: String
    
    // Relationships
    @NSManaged private(set) var subscriptions: Set<Subscription>
    @NSManaged public private(set) var site: Site
    @NSManaged private(set) var sales: Set<Sale>
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        createdAt = NSDate()
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
        return NSPredicate()
    }
    
    public static func defaultFetchRequest() -> NSFetchRequest {
        let request = NSFetchRequest(entityName: self.entityName)
        request.fetchLimit = 20
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: Product.Keys.CreatedAt.rawValue, ascending: false)]
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