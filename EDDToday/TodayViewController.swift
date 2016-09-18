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

@objc(TodayViewController)

class TodayViewController: UIViewController, NCWidgetProviding {
    
    let sharedDefaults: NSUserDefaults = NSUserDefaults(suiteName: "group.easydigitaldownloads.EDDSalesTracker")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredContentSize = CGSizeMake(0, 200)
        
        let vibrancyEffect: UIVibrancyEffect
        if #available(iOSApplicationExtension 10.0, *) {
            vibrancyEffect = UIVibrancyEffect.widgetPrimaryVibrancyEffect()
        } else {
            vibrancyEffect = UIVibrancyEffect.notificationCenterVibrancyEffect()
        }
        
        let visualEffectView = UIVisualEffectView(effect: vibrancyEffect)
        visualEffectView.frame = view.bounds
        visualEffectView.autoresizingMask = view.autoresizingMask
        
        let label = UILabel(frame: view.bounds)
        label.text = "Testing"
        label.textColor = .lightTextColor()
        label.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        
        view.addSubview(visualEffectView)
        visualEffectView.contentView.addSubview(label)
        
        guard let defaultSite = sharedDefaults.objectForKey("defaultSite") as? String,
            let documentsURL = NSFileManager.defaultManager()
                .containerURLForSecurityApplicationGroupIdentifier("group.easydigitaldownloads.EDDSalesTracker") else {
            return
        }
        
        let fileName = String(format: "/Stats-%@", defaultSite)
        let path = documentsURL.URLByAppendingPathComponent(fileName)!.path
        
        let statsClassObject = NSKeyedUnarchiver.unarchiveObjectWithFile(path!)
        print(statsClassObject)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.NewData)
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
}
