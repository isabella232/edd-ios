//
//  SequenceType+Utilities.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 31/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import Foundation

extension SequenceType {
    
    func findFirstOccurence(@noescape block: Generator.Element -> Bool) -> Generator.Element? {
        for x in self where block(x) {
            return x
        }
        return nil
    }
    
    func some(@noescape block: Generator.Element -> Bool) -> Bool {
        return findFirstOccurence(block) != nil
    }
    
    func all(@noescape block: Generator.Element -> Bool) -> Bool {
        return findFirstOccurence { !block($0) } == nil
    }
    
    /// Similar to
    /// ```
    /// func forEach(@noescape body: (Self.Generator.Element) -> ())
    /// ```
    /// but calls the completion block once all blocks have called their completion block. If some of the calls to the block do not call their completion blocks that will result in data leaking.
    func asyncForEachWithCompletion(completion: () -> (), @noescape block: (Generator.Element, () -> ()) -> ()) {
        let group = dispatch_group_create()
        let innerCompletion = { dispatch_group_leave(group) }
        for x in self {
            dispatch_group_enter(group)
            block(x, innerCompletion)
        }
        dispatch_group_notify(group, dispatch_get_main_queue(), completion)
    }
    
    func filterByType<T>() -> [T] {
        return filter { $0 is T }.map { $0 as! T }
    }
    
}


extension SequenceType where Generator.Element: AnyObject {
    
    public func containsObjectIdenticalTo(object: AnyObject) -> Bool {
        return contains { $0 === object }
    }
    
}