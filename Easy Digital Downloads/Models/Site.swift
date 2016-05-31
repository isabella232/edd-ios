//
//  Site.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 29/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import SSKeychain

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
    @NSManaged public private(set) var createdAt: NSDate?

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
    
    public static func insertIntoContext(moc: NSManagedObjectContext, uid: String, name: String, url: String, type: Int16, currency: String) -> Site {
        let site: Site = moc.insertObject()
        site.uid = uid
        site.name = name
        site.url = url
        site.type = NSNumber(short: type)
        site.currency = currency
        site.createdAt = NSDate()
        return site
    }
    
    public static func predicateForDefaultSite() -> NSPredicate {
        let defaultSiteId = NSUserDefaults.standardUserDefaults().stringForKey("defaultSite")!
        return NSPredicate(format: "uid == %@", defaultSiteId)
    }
    
    public static func defaultSite() -> Site {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        let site: Site = Site.fetchSingleObjectInContext(managedObjectContext, cacheKey: "defauleSiteObject") { (request) in
            request.predicate = self.predicateForDefaultSite()
            request.fetchLimit = 1
            }!

        let auth = SSKeychain.accountsForService(site.uid)
        let data = auth[0] as NSDictionary
        let acct = data.objectForKey("acct") as! String
        let password = SSKeychain.passwordForService(site.uid, account: acct)
        
        site.key = acct
        site.token = password

        return site
    }
    
    public static func lastActiveSite() -> String? {
        guard let activeSite = NSUserDefaults.standardUserDefaults().stringForKey("activeSite") else {
            return nil
        }

        return activeSite
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