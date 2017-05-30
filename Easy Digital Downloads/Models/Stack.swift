//
//  Stack.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 29/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import CoreData

private let StoreURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.easydigitaldownloads.EDDSalesTracker")!.appendingPathComponent("EDD.momd")

public func createEDDMainContext() -> NSManagedObjectContext {
    let bundles = [Bundle(for: Site.self)]
    
    guard let model = NSManagedObjectModel.mergedModel(from: bundles) else {
        fatalError("Module not found")
    }
    
    let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
    
    try! psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: StoreURL, options: nil)

    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    context.persistentStoreCoordinator = psc
    
    return context
}
