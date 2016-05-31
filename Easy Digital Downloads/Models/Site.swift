//
//  Site.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 29/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import Foundation
import CoreData

let CreatedTimestampKey = "createdAt"

enum SiteType: Int16 {
    case Standard = 0
    case Store = 1
    case Commission = 2
    case StandardStore = 3
    case StandardCommission = 4
}

public final class Site: ManagedObject {
    
    @NSManaged public private(set) var name: String?
    @NSManaged public private(set) var uid: String?
    @NSManaged public private(set) var url: String?
    @NSManaged public private(set) var type: NSNumber?
    @NSManaged public private(set) var currency: String?
    @NSManaged public private(set) var date: NSDate?

    var key: String = ""
    var token: String = ""
    
    var typeEnum: SiteType {
        get {
            return SiteType(rawValue: self.type!.shortValue) ?? .Standard
        }
        
        set {
            self.type = NSNumber(short: newValue.rawValue)
        }
    }
    
    public static func insertIntoContext(moc: NSManagedObjectContext, uid: String, name: String, url: String, type: NSNumber, currency: String) -> Site {
        let site: Site = moc.insertObject()
        site.uid = uid
        site.name = name
        site.url = url
        site.type = type
        site.currency = currency
        return site
    }

}

extension Site: ManagedObjectType {
    
    public static var entityName: String {
        return "Site"
    }
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: CreatedTimestampKey, ascending: false)]
    }
    
    public static var defaultPredicate: NSPredicate {
        return NSPredicate()
    }
    
}