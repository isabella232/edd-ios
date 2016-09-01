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
    @NSManaged private var createdAt: NSDate
    @NSManaged public private(set) var displayName: String
    @NSManaged public private(set) var email: String
    @NSManaged public private(set) var firstName: String
    @NSManaged public private(set) var lastName: String
    @NSManaged public private(set) var totalDownloads: Int16
    @NSManaged public private(set) var totalPurchases: Int16
    @NSManaged public private(set) var totalSpent: Double
    @NSManaged public private(set) var uid: String
    @NSManaged public private(set) var username: String
    
    // Relationships
    @NSManaged private(set) var subscriptions: Set<Subscription>
    @NSManaged private(set) var sales: Set<Sale>
    @NSManaged public private(set) var site: Site
        
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        createdAt = NSDate()
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
        return NSPredicate()
    }
    
}

extension Customer: KeyCodable {
    
    public enum Keys: String {
        case CreatedAt = "createdAt"
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