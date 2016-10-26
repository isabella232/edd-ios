//
//  GraphData.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 17/07/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

struct GraphData {
    
    let salesGraphDates: Array<String>
    let salesGraphData: Array<Int>
    let earningsGraphDates: Array<String>
    let earningsGraphData: Array<Double>
    
    static func encode(graphData: GraphData) {
        let storageAgent = GraphDataStorageAgent(graphData: graphData)
        
        NSKeyedArchiver.archiveRootObject(storageAgent, toFile: GraphDataStorageAgent.path())
    }
    
    static func decode() -> GraphData? {
        let graphDataClassObject = NSKeyedUnarchiver.unarchiveObjectWithFile(GraphDataStorageAgent.path()) as? GraphDataStorageAgent
        
        return graphDataClassObject?.graphData
    }
    
    static func hasGraphDataForActiveSite() -> Bool {
        let path = GraphDataStorageAgent.path()
        
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            return true
        } else {
            return false
        }
    }
    
}

extension GraphData {
    
    class GraphDataStorageAgent: NSObject, NSCoding {
        
        var graphData: GraphData?
        
        init(graphData: GraphData) {
            self.graphData = graphData
            super.init()
        }
        
        class func path() -> String {
            let documentsPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first
            let activeSite = Site.activeSite()
            let activeSiteUID = activeSite.uid!
            let fileName = String(format: "/GraphData-%@", activeSiteUID)
            let path = documentsPath?.stringByAppendingString(fileName)
            return path!
        }
        
        required init?(coder aDecoder: NSCoder) {
            guard let salesGraphDates = aDecoder.decodeObjectForKey("salesGraphDates") as? Array<String> else {
                graphData = nil
                super.init()
                return nil
            }
            
            guard let salesGraphData = aDecoder.decodeObjectForKey("salesGraphData") as? Array<Int> else {
                graphData = nil
                super.init()
                return nil
            }
            
            guard let earningsGraphDates = aDecoder.decodeObjectForKey("earningsGraphDates") as? Array<String> else {
                graphData = nil
                super.init()
                return nil
            }
            
            guard let earningsGraphData = aDecoder.decodeObjectForKey("earningsGraphData") as? Array<Double> else {
                graphData = nil
                super.init()
                return nil
            }
            
            graphData = GraphData(salesGraphDates: salesGraphDates, salesGraphData: salesGraphData, earningsGraphDates: earningsGraphDates, earningsGraphData: earningsGraphData)
            
            super.init()
        }
        
        func encodeWithCoder(aCoder: NSCoder) {
            aCoder.encodeObject(graphData!.salesGraphData, forKey: "salesGraphData")
            aCoder.encodeObject(graphData!.salesGraphDates, forKey: "salesGraphDates")
            aCoder.encodeObject(graphData!.earningsGraphData, forKey: "earningsGraphData")
            aCoder.encodeObject(graphData!.earningsGraphDates, forKey: "earningsGraphDates")
        }
        
    }
    
}
