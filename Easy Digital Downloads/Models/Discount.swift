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
    @NSManaged public private(set) var did: Int64
    @NSManaged public private(set) var expiryDate: NSDate?
    @NSManaged public private(set) var globalDiscount: NSNumber
    @NSManaged public private(set) var maxUses: Int64
    @NSManaged public private(set) var minPrice: Double
    @NSManaged public private(set) var name: String
    @NSManaged public private(set) var productRequirements: NSData?
    @NSManaged public private(set) var requirementConditions: String
    @NSManaged public private(set) var singleUse: NSNumber
    @NSManaged public private(set) var startDate: NSDate?
    @NSManaged public private(set) var status: String
    @NSManaged public private(set) var type: String
    @NSManaged public private(set) var uses: Int64
    
    // Relationships
    @NSManaged public private(set) var site: Site
    @NSManaged private(set) var sales: Set<Sale>
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        createdAt = NSDate()
    }
    
    public static func predicateForId(discountId: Int64) -> NSPredicate {
        return NSPredicate(format: "%K == %lld", Discount.Keys.ID.rawValue, discountId)
    }

    public static func insertIntoContext(moc: NSManagedObjectContext, amount: Double, code: String, did: Int64, expiryDate: NSDate?, globalDiscount: NSNumber, maxUses: Int64, minPrice: Double, name: String, productRequirements: NSData?, requirementConditions: String, singleUse: NSNumber, startDate: NSDate?, status: String, type: String, uses: Int64) -> Discount {
        let discount: Discount = moc.insertObject()
        discount.amount = amount
        discount.code = code
        discount.did = did
        discount.expiryDate = expiryDate
        discount.globalDiscount = globalDiscount
        discount.maxUses = maxUses
        discount.minPrice = minPrice
        discount.name = name
        discount.productRequirements = productRequirements
        discount.requirementConditions = requirementConditions
        discount.singleUse = singleUse
        discount.startDate = startDate
        discount.status = status
        discount.type = type
        discount.uses = uses
        discount.site = Site.fetchRecordForActiveSite(inContext: moc)
        
        return discount
    }
    
}

extension Discount: ManagedObjectType {
    
    public static var entityName: String {
        return "Discount"
    }
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: CreatedTimestampKey, ascending: false)]
    }
    
    public static var defaultPredicate: NSPredicate {
        return NSPredicate(format: "site.uid == %@", Site.activeSite().uid!)
    }
    
    public static func defaultFetchRequest() -> NSFetchRequest {
        let request = NSFetchRequest(entityName: self.entityName)
        request.fetchLimit = 20
        request.predicate = defaultPredicate
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: Discount.Keys.ID.rawValue, ascending: false)]
        return request
    }
    
}

extension Discount: KeyCodable {
    
    public enum Keys: String {
        case Amount = "amount"
        case Code = "code"
        case ID = "did"
        case ExpiryDate = "expiryDate"
        case GlobalDiscount = "globalDiscount"
        case MaxUses = "maxUses"
        case MinPrice = "minPrice"
        case Name = "name"
        case ProductRequirements = "productRequirements"
        case RequirementConditions = "requirementConditions"
        case SingleUse = "singleUse"
        case StartDate = "startDate"
        case Status = "status"
        case Type = "type"
        case Uses = "uses"
    }
    
}
