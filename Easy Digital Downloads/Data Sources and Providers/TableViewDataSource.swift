//
//  TableViewDataSource.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 29/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit


class TableViewDataSource<Delegate: DataSourceDelegate, Data: DataProvider, Cell: UITableViewCell>: NSObject, UITableViewDataSource where Delegate.Object == Data.Object, Cell: ConfigurableCell, Cell.DataSource == Data.Object {
    
    required init(tableView: UITableView, dataProvider: Data, delegate: Delegate) {
        self.tableView = tableView
        self.dataProvider = dataProvider
        self.delegate = delegate
        super.init()
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    var selectedObject: Data.Object? {
        guard let indexPath = tableView.indexPathForSelectedRow else { return nil }
        return dataProvider.objectAtIndexPath(indexPath)
    }
    
    func objectAtIndexPath(_ indexPath: IndexPath) -> Data.Object? {
        return dataProvider.objectAtIndexPath(indexPath)
    }
    
    func processUpdates(_ updates: [DataProviderUpdate<Data.Object>]?) {
        guard let updates = updates else { return tableView.reloadData() }
        tableView.beginUpdates()
        for update in updates {
            switch update {
            case .insert(let indexPath):
                tableView.insertRows(at: [indexPath], with: .fade)
            case .update(let indexPath, let object):
                guard let cell = tableView.cellForRow(at: indexPath) as? Cell else { break }
                cell.configureForObject(object)
            case .move(let indexPath, let newIndexPath):
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.insertRows(at: [newIndexPath], with: .fade)
            case .delete(let indexPath):
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
        tableView.endUpdates()
    }
    
    
    // MARK: Private
    
    fileprivate let tableView: UITableView
    fileprivate let dataProvider: Data
    fileprivate weak var delegate: Delegate!
    
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProvider.numberOfItemsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = dataProvider.objectAtIndexPath(indexPath)
        let identifier = delegate.cellIdentifierForObject(object)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? Cell
            else { fatalError("Unexpected cell type at \(indexPath)") }
        cell.configureForObject(object)
        return cell
    }
    
}
