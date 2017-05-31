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
    
    public static func convertFromData(_ data:Data) -> Result? {
        if let obj = NSKeyedUnarchiver.unarchiveObject(with: data) {
            return Result(obj)
        }

        return nil
    }
    
    public func asData() -> Data! {
        var obj: AnyObject! = self.dictionaryObject as AnyObject
        if obj == nil {
            obj = self.arrayObject as AnyObject
        }
        if obj != nil {
            return (NSKeyedArchiver.archivedData(withRootObject: obj!) as NSData) as Data!
        }
        return nil
    }
}
