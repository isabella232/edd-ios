//
//  Stack.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 29/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import CoreData

private let StoreURL = NSURL.documentsURL.URLByAppendingPathComponent("EDD.momd")

public func createEDDMainContext() -> NSManagedObjectContext {
    let bundles = [NSBundle(forClass: Site.self)]
    
    guard let model = NSManagedObjectModel.mergedModelFromBundles(bundles) else {
        fatalError("Module not found")
    }
    
    let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
    
    try! psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: StoreURL, options: nil)

    let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    context.persistentStoreCoordinator = psc
    
    return context
}