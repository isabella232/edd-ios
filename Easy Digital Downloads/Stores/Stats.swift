//
//  Stats.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 14/06/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import Foundation
import UIKit

struct Stats {
    
    var sales: NSDictionary
    var earnings: NSDictionary
    var commissions: NSDictionary?
    var storeCommissions: NSDictionary?
    var updatedAt: Date
    
    static func encode(_ stats: Stats) {
        let statsClassObject = StatsStorageAgent(stats: stats)
        
        NSKeyedArchiver.archiveRootObject(statsClassObject, toFile: StatsStorageAgent.path())
    }
    
    static func decode() -> Stats? {
        let statsClassObject = NSKeyedUnarchiver.unarchiveObject(withFile: StatsStorageAgent.path()) as? StatsStorageAgent
        
        return statsClassObject?.stats
    }
    
    static func hasStatsForActiveSite() -> Bool {
        let path = StatsStorageAgent.path()
        
        if FileManager.default.fileExists(atPath: path) {
            return true
        } else {
            return false
        }
    }
    
}

extension Stats {

    class StatsStorageAgent: NSObject, NSCoding {
        
        var stats: Stats?
        
        init(stats: Stats) {
            self.stats = stats
            super.init()
        }
        
        class func path() -> String {
            let documentsURL = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: "group.easydigitaldownloads.EDDSalesTracker")
            let activeSite = Site.activeSite()
            let activeSiteUID = activeSite.uid!
            let fileName = String(format: "/Stats-%@", activeSiteUID)
            let path = documentsURL?.appendingPathComponent(fileName).path
            return path!
        }
        
        required init?(coder aDecoder: NSCoder) {
            guard let sales = aDecoder.decodeObject(forKey: "sales") as? NSDictionary else { stats = nil; super.init(); return nil }
            guard let earnings = aDecoder.decodeObject(forKey: "earnings") as? NSDictionary else { stats = nil; super.init(); return nil }
            guard let commissions = aDecoder.decodeObject(forKey: "commissions") as? NSDictionary else { stats = nil; super.init(); return nil }
            guard let storeCommissions = aDecoder.decodeObject(forKey: "storeCommissions") as? NSDictionary else { stats = nil; super.init(); return nil }
            guard let updatedAt = aDecoder.decodeObject(forKey: "updatedAt") as? Date else { stats = nil; super.init(); return nil }
            
            stats = Stats(sales: sales, earnings: earnings, commissions: commissions, storeCommissions: storeCommissions, updatedAt: updatedAt)
            
            super.init()
        }
        
        func encode(with aCoder: NSCoder) {
            aCoder.encode(stats!.sales, forKey: "sales")
            aCoder.encode(stats!.earnings, forKey: "earnings")
            
            if let commissions = stats?.commissions {
                aCoder.encode(commissions, forKey: "commissions")
            }
            
            if let storeCommissions = stats?.storeCommissions {
                aCoder.encode(storeCommissions, forKey: "storeCommissions")
            }

            aCoder.encode(stats!.updatedAt, forKey: "updatedAt")
        }
        
    }

}
