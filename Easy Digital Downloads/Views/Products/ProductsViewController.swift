//
//  ProductsViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 01/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON

class ProductsViewController: SiteTableViewController, ManagedObjectContextSettable {

    var managedObjectContext: NSManagedObjectContext!
    
    var site: Site?
    var products: [JSON]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInfiniteScrollView()
        setupTableView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    init(site: Site) {
        super.init(style: .Plain)
        
        self.site = site
        self.managedObjectContext = AppDelegate.sharedInstance.managedObjectContext
        
        title = NSLocalizedString("Products", comment: "Products title")
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        products = [JSON]()
        
        EDDAPIWrapper.sharedInstance.requestProducts([:], success: { (json) in
            if let items = json["products"].array {
                for item in items {
                    self.products?.append(item)
                }
            }
            self.persistProducts()
        }) { (error) in
            NSLog(error.localizedDescription)
        }
    }
    
    // MARK: Private
    
    private func requestNextPage() {
        
    }
    
    private func persistProducts() {
        guard products != nil else {
            return
        }
    }
    
    private typealias Data = FetchedResultsDataProvider<ProductsViewController>
    private var dataSource: TableViewDataSource<ProductsViewController, Data, ProductsTableViewCell>!
    
    private func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.registerClass(ProductsTableViewCell.self, forCellReuseIdentifier: "ProductCell")
        setupDataSource()
    }
    
    private func setupDataSource() {
        let request = Product.defaultFetchRequest()
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        let dataProvider = FetchedResultsDataProvider(fetchedResultsController: frc, delegate: self)
        dataSource = TableViewDataSource(tableView: tableView, dataProvider: dataProvider, delegate: self)
    }

}

extension ProductsViewController: DataProviderDelegate {
    
    func dataProviderDidUpdate(updates: [DataProviderUpdate<Product>]?) {
        dataSource.processUpdates(updates)
    }
    
}

extension ProductsViewController: DataSourceDelegate {
    
    func cellIdentifierForObject(object: Product) -> String {
        return "ProductCell"
    }
    
}


extension ProductsViewController : InfiniteScrollingTableView {
    
    func setupInfiniteScrollView() {
        let bounds = UIScreen.mainScreen().bounds
        let width = bounds.size.width
        
        let footerView = UIView(frame: CGRectMake(0, 0, width, 44))
        footerView.backgroundColor = .clearColor()
        
        activityIndicatorView.startAnimating()
        
        footerView.addSubview(activityIndicatorView)
        
        tableView.tableFooterView = footerView
    }
    
}