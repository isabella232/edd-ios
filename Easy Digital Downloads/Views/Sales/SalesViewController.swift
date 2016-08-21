//
//  SalesViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 28/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData

class SalesViewController: UITableViewController, NSFetchedResultsControllerDelegate, ManagedObjectContextSettable {

    var managedObjectContext: NSManagedObjectContext!

    var site: Site?
    var sales: NSDictionary?
//    var sales = [Sales]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    init(site: Site) {
        super.init(style: .Plain)
        
        self.site = site
        
        title = NSLocalizedString("Sales", comment: "Sales title")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = estimatedHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        sales = NSDictionary()
        
        EDDAPIWrapper.sharedInstance.requestSales([ : ], success: { (json) in
            sales = NSDictionary(dictionary: json.dictionaryObject!)
            saveSales()
            }) { (error) in
                fatalError()
        }
    }
    
    private func saveSales() {
        guard let sales = sales_ else { return nil }
        
        
    }
}
