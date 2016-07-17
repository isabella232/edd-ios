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
    
    let sales: NSDictionary
    let earnings: NSDictionary
    let commissions: NSDictionary
    let storeCommissions: NSDictionary
    let updatedAt: NSDate
    
    static func encode(stats: Stats) {
        let statsClassObject = StatsStorageAgent(stats: stats)
        
        NSKeyedArchiver.archiveRootObject(statsClassObject, toFile: StatsStorageAgent.path())
    }
    
    static func decode() -> Stats? {
        let statsClassObject = NSKeyedUnarchiver.unarchiveObjectWithFile(StatsStorageAgent.path()) as? StatsStorageAgent
        
        return statsClassObject?.stats
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
            let documentsPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first
            let path = documentsPath?.stringByAppendingString("/Stats")
            return path!
        }
        
        required init?(coder aDecoder: NSCoder) {
            guard let sales = aDecoder.decodeObjectForKey("sales") as? NSDictionary else { stats = nil; super.init(); return nil }
            guard let earnings = aDecoder.decodeObjectForKey("earnings") as? NSDictionary else { stats = nil; super.init(); return nil }
            guard let commissions = aDecoder.decodeObjectForKey("commissions") as? NSDictionary else { stats = nil; super.init(); return nil }
            guard let storeCommissions = aDecoder.decodeObjectForKey("storeCommissions") as? NSDictionary else { stats = nil; super.init(); return nil }
            guard let updatedAt = aDecoder.decodeObjectForKey("updatedAt") as? NSDate else { stats = nil; super.init(); return nil }
            
            stats = Stats(sales: sales, earnings: earnings, commissions: commissions, storeCommissions: storeCommissions, updatedAt: updatedAt)
            
            super.init()
        }
        
        func encodeWithCoder(aCoder: NSCoder) {
            aCoder.encodeObject(stats!.sales, forKey: "sales")
            aCoder.encodeObject(stats!.earnings, forKey: "earnings")
            aCoder.encodeObject(stats!.commissions, forKey: "commissions")
            aCoder.encodeObject(stats!.storeCommissions, forKey: "storeCommissions")
            aCoder.encodeObject(stats!.updatedAt, forKey: "updatedAt")
        }
        
    }

}