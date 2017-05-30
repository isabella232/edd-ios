//
//  NSURL+Utilities.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 29/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import Foundation

extension URL {

    static func temporaryURL() -> URL {
        return try! FileManager.default.url(for: FileManager.SearchPathDirectory.cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(UUID().uuidString)
    }
    
    static var documentsURL: URL {
        return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }

}
