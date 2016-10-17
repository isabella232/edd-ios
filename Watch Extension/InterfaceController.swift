//
//  InterfaceController.swift
//  Watch Extension
//
//  Created by Sunny Ratilal on 05/10/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import Alamofire
import SwiftyJSON

class InterfaceController: WKInterfaceController {

    @IBOutlet var tableView: WKInterfaceTable!
    
    var session: WCSession!
    
    var items = ["Active Site", "Sales", "Earnings"]
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        tableView.setNumberOfRows(3, withRowType: "DashboardRow")
        
        var i = 0
        for item in items {
            let row = tableView.rowControllerAtIndex(i) as! DashboardRowObject
            row.label.setText(item)
            i += 1
        }
    }
    
    override init() {
        super.init()
        
        addMenuItemWithItemIcon(.Resume, title: NSLocalizedString("Refresh", comment: ""), action: #selector(InterfaceController.onRefreshIconTap))
    }
    
    func onRefreshIconTap() {
        
    }
    
    override func willActivate() {
        super.willActivate()
        
        
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }

}
