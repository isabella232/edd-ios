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

private let sharedDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}()

class SubscriptionsDetailViewController: SiteTableViewController {
    
    private enum CellType {
        case Billing
        case RenewalPayments
        case Licensing
    }
    
    private var cells = [CellType]()

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
        
        tableView.registerClass(SubscriptionsDetailBillingTableViewCell.self, forCellReuseIdentifier: "SubscriptionsDetailBillingTableViewCell")
        tableView.registerClass(SubscriptionsDetailRenewalPaymentsTableViewCell.self, forCellReuseIdentifier: "SubscriptionsDetailRenewalPaymentsTableViewCell")
        tableView.registerClass(SubscriptionsDetailLicensingTableViewCell.self, forCellReuseIdentifier: "SubscriptionsDetailLicensingTableViewCell")
        
        cells = [.Billing, .RenewalPayments, .Licensing]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Table View Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    // MARK: Table View Delegate
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        switch cells[indexPath.row] {
            case .Billing:
                cell = tableView.dequeueReusableCellWithIdentifier("SubscriptionsDetailBillingTableViewCell", forIndexPath: indexPath) as! SubscriptionsDetailBillingTableViewCell
            case .RenewalPayments:
                cell = tableView.dequeueReusableCellWithIdentifier("SubscriptionsDetailRenewalPaymentsTableViewCell", forIndexPath: indexPath) as! SubscriptionsDetailRenewalPaymentsTableViewCell
            case .Licensing:
                cell = tableView.dequeueReusableCellWithIdentifier("SubscriptionsDetailLicensingTableViewCell", forIndexPath: indexPath) as! SubscriptionsDetailLicensingTableViewCell
        }
        
        return cell!
    }

}
