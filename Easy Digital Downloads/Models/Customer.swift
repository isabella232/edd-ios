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
    @NSManaged public private(set) var createdAt: NSDate
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
    
}
