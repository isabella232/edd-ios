//
//  SalesViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 28/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData

class SalesViewController: UITableViewController, ManagedObjectContextSettable {
    
    var managedObjectContext: NSManagedObjectContext!

    var site: Site?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSLog("Sales loaded")
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
