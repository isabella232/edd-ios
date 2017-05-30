//
//  JSON+Cache.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 02/10/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Haneke

extension SwiftyJSON.JSON : DataConvertible, DataRepresentable {
    
    public typealias Result = SwiftyJSON.JSON
    
    public static func convertFromData(_ data:NSData) -> Result? {
        if let obj: AnyObject = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! (Data) as (Data) as AnyObject {
            return SwiftyJSON.JSON(obj)
        }
        return null
    }
    
    public func asData() -> NSData! {
        var obj: AnyObject! = self.dictionaryObject
        if obj == nil {
            obj = self.arrayObject
        }
        if obj != nil {
            return NSKeyedArchiver.archivedDataWithRootObject(obj!)
        }
        return nil
    }
}
