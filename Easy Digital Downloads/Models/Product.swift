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
    @NSManaged public private(set) var createdAt: NSDate
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
    
}
