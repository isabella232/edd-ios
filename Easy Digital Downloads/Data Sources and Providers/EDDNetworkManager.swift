//
//  EDDNetworkManager.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 26/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import Foundation
import Alamofire

class EDDNetworkManager {
    
    static let sharedInstance: SessionManager = {
        let urlCache: URLCache = {
            let capacity = 50 * 1024 * 1024 // MBs
            let urlCache = URLCache(memoryCapacity: capacity, diskCapacity: capacity, diskPath: "shared_cache")
            
            return urlCache
        }()
        
        let configuration: URLSessionConfiguration = {
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
            configuration.requestCachePolicy = .useProtocolCachePolicy // this is the default
            configuration.urlCache = urlCache

            return configuration
        }()

        let manager = SessionManager(configuration: configuration)
        
        return manager
    }()

}
