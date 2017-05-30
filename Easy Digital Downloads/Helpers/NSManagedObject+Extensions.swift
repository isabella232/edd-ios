//
//  NSManagedObject+Extensions.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 31/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {

    public func refresh(_ mergeChanges: Bool = true) {
        managedObjectContext?.refresh(self, mergeChanges: mergeChanges)
    }

}
