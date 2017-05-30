//
//  DataProvider.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 29/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

protocol DataProvider: class {

    associatedtype Object
    func objectAtIndexPath(_ indexPath: IndexPath) -> Object
    func numberOfItemsInSection(_ section: Int) -> Int

}

protocol DataProviderDelegate: class {

    associatedtype Object
    func dataProviderDidUpdate(_ updates: [DataProviderUpdate<Object>]?)

}

enum DataProviderUpdate<Object> {

    case insert(IndexPath)
    case update(IndexPath, Object)
    case move(IndexPath, IndexPath)
    case delete(IndexPath)

}
