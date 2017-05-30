//
//  AugmentedDataProviderDelegate.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 21/08/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import CoreData

protocol AugmentedDataProviderDelegate: DataProviderDelegate {
    func numberOfAdditionalRows() -> Int
    func presentedIndexPathForFetchedIndexPath(_ indexPath: IndexPath) -> IndexPath
    func fetchedIndexPathForPresentedIndexPath(_ indexPath: IndexPath) -> IndexPath
    func supplementaryObjectAtPresentedIndexPath(_ indexPath: IndexPath) -> Object?
}


/// Note: this class doesn't support working with multiple sections
class AugmentedFetchedResultsDataProvider<Delegate: AugmentedDataProviderDelegate>: DataProvider {
    
    typealias Object = Delegate.Object
    
    init(fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>, delegate: Delegate) {
        self.delegate = delegate
        frcDataProvider = FetchedResultsDataProvider(fetchedResultsController: fetchedResultsController, delegate: self)
    }
    
    func reconfigureFetchRequest(_ block: (NSFetchRequest<NSFetchRequestResult>) -> ()) {
        frcDataProvider.reconfigureFetchRequest(block)
    }
    
    func objectAtIndexPath(_ indexPath: IndexPath) -> Object {
        if let o = delegate.supplementaryObjectAtPresentedIndexPath(indexPath) {
            return o
        }
        let frcIndexPath = delegate.fetchedIndexPathForPresentedIndexPath(indexPath)
        return frcDataProvider.objectAtIndexPath(frcIndexPath)
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return frcDataProvider.numberOfItemsInSection(section) + delegate.numberOfAdditionalRows()
    }
    
    
    // MARK: Private
    
    fileprivate var frcDataProvider: FetchedResultsDataProvider<AugmentedFetchedResultsDataProvider>!
    fileprivate weak var delegate: Delegate!
    
}


extension AugmentedFetchedResultsDataProvider: DataProviderDelegate {
    func dataProviderDidUpdate(_ updates: [DataProviderUpdate<Object>]?) {
        let transformedUpdates = updates?.map { $0.updateByTransformingIndexPath(delegate.presentedIndexPathForFetchedIndexPath) }
        delegate.dataProviderDidUpdate(transformedUpdates)
    }
}


extension DataProviderUpdate {
    fileprivate func updateByTransformingIndexPath(_ transformer: (IndexPath) -> IndexPath) -> DataProviderUpdate {
        switch self {
        case .delete(let indexPath): return .delete(transformer(indexPath))
        case .update(let indexPath, let o): return .update(transformer(indexPath), o)
        case .move(let indexPath, let newIndexPath): return .move(transformer(indexPath), transformer(newIndexPath))
        case .insert(let indexPath): return .insert(transformer(indexPath))
        }
    }
}


extension AugmentedDataProviderDelegate {
    func numberOfAdditionalRows() -> Int {
        return 0
    }
    
    func presentedIndexPathForFetchedIndexPath(_ indexPath: IndexPath) -> IndexPath {
        return IndexPath(row: indexPath.row + numberOfAdditionalRows(), section: indexPath.section)
    }
    
    func fetchedIndexPathForPresentedIndexPath(_ indexPath: IndexPath) -> IndexPath {
        return IndexPath(row: indexPath.row - numberOfAdditionalRows(), section: indexPath.section)
    }
    
    func supplementaryObjectAtPresentedIndexPath(_ indexPath: IndexPath) -> Object? {
        return nil
    }
}

