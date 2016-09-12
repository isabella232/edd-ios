//
//  TodayViewController.swift
//  EDDToday
//
//  Created by Sunny Ratilal on 22/08/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import NotificationCenter
import SwiftyJSON
import CoreData

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var salesLabel: UILabel!
    @IBOutlet weak var earningsLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.NewData)
    }
    
}
