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
    @NSManaged public private(set) var amount: NSNumber
    @NSManaged public private(set) var currency: String
    @NSManaged public private(set) var date: NSDate
    @NSManaged public private(set) var item: String
    @NSManaged public private(set) var rate: NSNumber
    @NSManaged public private(set) var renewal: Int
    @NSManaged public private(set) var status: String
    
    // Relationships
    @NSManaged public private(set) var site: Site
    
}
