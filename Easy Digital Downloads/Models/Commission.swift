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
    @NSManaged public private(set) var renewal: Int64
    @NSManaged public private(set) var status: String
    
    // Relationships
    @NSManaged public private(set) var site: Site
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        createdAt = NSDate()
    }
    
    public static func insertIntoContext(moc: NSManagedObjectContext, amount: Double, currency: String, date: NSDate, item: String, rate: Double, renewal: Int64, status: String) -> Commission {
        let commission: Commission = moc.insertObject()
        commission.amount = amount
        commission.currency = currency
        commission.date = date
        commission.item = item
        commission.rate = rate
        commission.renewal = renewal
        commission.site = Site.fetchRecordForActiveSite(inContext: moc)
        commission.status = status
        
        return commission
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
        return NSPredicate(format: "site.uid == %@", Site.activeSite().uid!)
    }
    
    public static func defaultFetchRequest() -> NSFetchRequest {
        let request = NSFetchRequest(entityName: self.entityName)
        request.fetchLimit = 20
        request.predicate = defaultPredicate
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
