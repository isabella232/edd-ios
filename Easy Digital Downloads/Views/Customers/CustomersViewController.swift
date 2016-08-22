//
//  CustomersViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 28/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData

class CustomersViewController: SiteTableViewController, ManagedObjectContextSettable {

    var managedObjectContext: NSManagedObjectContext!
    
    var site: Site?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    init(site: Site) {
        super.init(style: .Plain)
        
        self.site = site
        
        title = NSLocalizedString("Customers", comment: "Customers title")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = estimatedHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
