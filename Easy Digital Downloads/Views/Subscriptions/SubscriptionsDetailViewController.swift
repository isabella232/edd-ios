//
//  SubscriptionsDetailViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 26/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON

class SubscriptionsDetailViewController: SiteTableViewController {

    var site: Site?
    var subscription: Subscription?
    
    init(subscription: Subscription) {
        super.init(style: .Plain)
        
        self.site = Site.activeSite()
        self.subscription = subscription
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
        
        title = NSLocalizedString("Subscription", comment: "") + " #" + "\(subscription.sid)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Table View Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

}
