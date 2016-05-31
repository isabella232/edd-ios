//
//  ManagedObjectType.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 29/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import CoreData

public protocol ManagedObjectType: class {

    static var entityName: String { get }
    static var defaultSortDescriptors:[NSSortDescriptor] { get }

}

extension ManagedObjectType {

    public static var defaultSortDescriptors:[NSSortDescriptor] {
        return []
    }
    
    public static var sortedFetchRequest: NSFetchRequest {
        let request = NSFetchRequest(entityName: entityName)
        request.sortDescriptors = defaultSortDescriptors
        return request
    }

}