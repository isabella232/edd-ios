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
    
    static func encode(_ graphData: GraphData) {
        let storageAgent = GraphDataStorageAgent(graphData: graphData)
        
        NSKeyedArchiver.archiveRootObject(storageAgent, toFile: GraphDataStorageAgent.path())
    }
    
    static func decode() -> GraphData? {
        let graphDataClassObject = NSKeyedUnarchiver.unarchiveObject(withFile: GraphDataStorageAgent.path()) as? GraphDataStorageAgent
        
        return graphDataClassObject?.graphData
    }
    
    static func hasGraphDataForActiveSite() -> Bool {
        let path = GraphDataStorageAgent.path()
        
        if FileManager.default.fileExists(atPath: path) {
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
            let documentsPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
            let activeSite = Site.activeSite()
            let activeSiteUID = activeSite.uid!
            let fileName = String(format: "/GraphData-%@", activeSiteUID)
            let path = (documentsPath)! + fileName
            return path
        }
        
        required init?(coder aDecoder: NSCoder) {
            guard let salesGraphDates = aDecoder.decodeObject(forKey: "salesGraphDates") as? Array<String> else {
                graphData = nil
                super.init()
                return nil
            }
            
            guard let salesGraphData = aDecoder.decodeObject(forKey: "salesGraphData") as? Array<Int> else {
                graphData = nil
                super.init()
                return nil
            }
            
            guard let earningsGraphDates = aDecoder.decodeObject(forKey: "earningsGraphDates") as? Array<String> else {
                graphData = nil
                super.init()
                return nil
            }
            
            guard let earningsGraphData = aDecoder.decodeObject(forKey: "earningsGraphData") as? Array<Double> else {
                graphData = nil
                super.init()
                return nil
            }
            
            graphData = GraphData(salesGraphDates: salesGraphDates, salesGraphData: salesGraphData, earningsGraphDates: earningsGraphDates, earningsGraphData: earningsGraphData)
            
            super.init()
        }
        
        func encode(with aCoder: NSCoder) {
            aCoder.encode(graphData!.salesGraphData, forKey: "salesGraphData")
            aCoder.encode(graphData!.salesGraphDates, forKey: "salesGraphDates")
            aCoder.encode(graphData!.earningsGraphData, forKey: "earningsGraphData")
            aCoder.encode(graphData!.earningsGraphDates, forKey: "earningsGraphDates")
        }
        
    }
    
}
