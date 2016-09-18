//
//  Commission.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 17/07/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData

public final class Commission: ManagedObject {

    // Attributes
    @NSManaged private var createdAt: NSDate
    @NSManaged public private(set) var amount: NSNumber
    @NSManaged public private(set) var currency: String
    @NSManaged public private(set) var date: NSDate
    @NSManaged public private(set) var item: String
    @NSManaged public private(set) var rate: NSNumber
    @NSManaged public private(set) var renewal: Int
    @NSManaged public private(set) var status: String
    
    // Relationships
    @NSManaged public private(set) var site: Site
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        createdAt = NSDate()
    }
    
}

extension Commission: ManagedObjectType {
 
    public static var entityName: String {
        return "Commission"
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
        request.sortDescriptors = [NSSortDescriptor(key: Commission.Keys.CreatedAt.rawValue, ascending: false)]
        return request
    }

}

extension Commission: KeyCodable {
    
    public enum Keys: String {
        case Amount = "amount"
        case CreatedAt = "createdAt"
        case Currency = "currency"
        case Date = "date"
        case Item = "item"
        case Rate = "rate"
        case Renewal = "renewal"
        case Status = "status"
    }
    
}
