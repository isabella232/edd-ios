//
//  Discount.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 17/07/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData

public final class Discount: ManagedObject {

    // Attributes
    @NSManaged private var createdAt: NSDate
    @NSManaged public private(set) var amount: Double
    @NSManaged public private(set) var code: String
    @NSManaged public private(set) var did: Int16
    @NSManaged public private(set) var expiryDate: NSDate
    @NSManaged public private(set) var globalDiscount: NSNumber
    @NSManaged public private(set) var maxUses: Int16
    @NSManaged public private(set) var minPrice: Double
    @NSManaged public private(set) var name: String
    @NSManaged public private(set) var productRequirements: NSArray
    @NSManaged public private(set) var requirementConditions: String
    @NSManaged public private(set) var singleUse: NSNumber
    @NSManaged public private(set) var startDate: NSDate
    @NSManaged public private(set) var status: String
    @NSManaged public private(set) var type: String
    @NSManaged public private(set) var uses: Int16
    
    // Relationships
    @NSManaged public private(set) var site: Site
    @NSManaged private(set) var sales: Set<Sale>
    
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        createdAt = NSDate()
    }

}
