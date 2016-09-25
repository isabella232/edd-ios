//
//  Subscription.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 17/07/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData

public final class Subscription: ManagedObject {

    // Attributes
    @NSManaged private var createdAt: NSDate
    @NSManaged public private(set) var billTimes: Int16
    @NSManaged public private(set) var customer: [String: AnyObject]
    @NSManaged public private(set) var created: NSDate
    @NSManaged public private(set) var expiration: NSDate
    @NSManaged public private(set) var gateway: String
    @NSManaged public private(set) var initialAmount: Double
    @NSManaged public private(set) var parentPaymentID: Int16
    @NSManaged public private(set) var period: String
    @NSManaged public private(set) var pid: Int16
    @NSManaged public private(set) var profileID: String
    @NSManaged public private(set) var recurringAmount: Double
    @NSManaged public private(set) var sid: Int16
    @NSManaged public private(set) var status: String
    
    // Relationships
    @NSManaged public private(set) var site: Site
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        createdAt = NSDate()
    }
    
}
