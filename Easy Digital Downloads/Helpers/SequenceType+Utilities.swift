//
//  SequenceType+Utilities.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 31/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import Foundation

extension Sequence {
    
    func findFirstOccurence(_ block: (Iterator.Element) -> Bool) -> Iterator.Element? {
        for x in self where block(x) {
            return x
        }
        return nil
    }
    
    func some(_ block: (Iterator.Element) -> Bool) -> Bool {
        return findFirstOccurence(block) != nil
    }
    
    func all(_ block: (Iterator.Element) -> Bool) -> Bool {
        return findFirstOccurence { !block($0) } == nil
    }
    
    /// Similar to
    /// ```
    /// func forEach(@noescape body: (Self.Generator.Element) -> ())
    /// ```
    /// but calls the completion block once all blocks have called their completion block. If some of the calls to the block do not call their completion blocks that will result in data leaking.
    func asyncForEachWithCompletion(_ completion: @escaping () -> (), block: (Iterator.Element, () -> ()) -> ()) {
        let group = DispatchGroup()
        let innerCompletion = { group.leave() }
        for x in self {
            group.enter()
            block(x, innerCompletion)
        }
        group.notify(queue: DispatchQueue.main, execute: completion)
    }
    
    func filterByType<T>() -> [T] {
        return filter { $0 is T }.map { $0 as! T }
    }
    
}


extension Sequence where Iterator.Element: AnyObject {
    
    public func containsObjectIdenticalTo(_ object: AnyObject) -> Bool {
        return contains { $0 === object }
    }
    
}
