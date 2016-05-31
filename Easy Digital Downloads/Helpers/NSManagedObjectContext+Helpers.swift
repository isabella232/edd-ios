//
//  NSManagedObjectContext+Helpers.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 30/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
    
    public func insertObject<A: ManagedObject where A: ManagedObjectType>() -> A {
        guard let obj = NSEntityDescription.insertNewObjectForEntityForName(A.entityName, inManagedObjectContext: self) as? A else { fatalError("Wrong object type") }
        return obj
    }
    
    public func saveOrRollback() -> Bool {
        do {
            try save()
            return true
        } catch {
            rollback()
            return false
        }
    }
    
    public func performChanges(block: () -> ()) {
        performBlock { 
            block()
            self.saveOrRollback()
        }
    }
    
}