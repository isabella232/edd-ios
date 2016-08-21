//
//  Sale.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 17/07/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData

public final class Sale: ManagedObject {

    // Attributes
    @NSManaged private var createdAt: NSDate
    @NSManaged public private(set) var date: NSDate
    @NSManaged public private(set) var email: String
    @NSManaged public private(set) var fees: NSDictionary
    @NSManaged public private(set) var gateway: String
    @NSManaged public private(set) var key: String
    @NSManaged public private(set) var sid: Int16
    @NSManaged public private(set) var subtotal: Double
    @NSManaged public private(set) var tax: Double
    @NSManaged public private(set) var total: Double
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
    
}
