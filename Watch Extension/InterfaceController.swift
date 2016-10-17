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

class InterfaceController: WKInterfaceController {

    @IBOutlet var tableView: WKInterfaceTable!
    
    var session: WCSession!
    
    var items = ["Sales", "Earnings"]

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        tableView.setNumberOfRows(2, withRowType: "DashboardRow")
        
        var i = 0
        for item in items {
            let row = tableView.rowController(at: i) as! DashboardRowObject
            row.label.setText(item)
            i += 1
        }
    }
    
    override func willActivate() {
        super.willActivate()
        
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }

}
