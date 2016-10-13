//
//  InterfaceController.swift
//  Watch Extension
//
//  Created by Sunny Ratilal on 05/10/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {

    @IBOutlet var tableView: WKInterfaceTable!
    
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
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
