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
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequset = NSFetchRequest(entityName: "Sale")
    }
    
    var managedObjectContext: NSManagedObjectContext!

    var site: Site?
    
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
        
        var sales: NSDictionary = NSDictionary()
        
        EDDAPIWrapper.sharedInstance.requestSales([ : ], success: { (json) in
            sales = NSDictionary(dictionary: json.dictionaryObject!)
            print(sales)
            }) { (error) in
                fatalError()
        }
    }

}
