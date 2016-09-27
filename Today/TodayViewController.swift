//
//  TodayViewController.swift
//  Today
//
//  Created by Sunny Ratilal on 27/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import Alamofire
import SSKeychain
import SwiftyJSON
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    let sharedDefaults: NSUserDefaults = NSUserDefaults(suiteName: "group.easydigitaldownloads.EDDSalesTracker")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredContentSize = CGSizeMake(0, 200)
        
        let vibrancyEffect: UIVibrancyEffect
        vibrancyEffect = UIVibrancyEffect.widgetPrimaryVibrancyEffect()
        
        let visualEffectView = UIVisualEffectView(effect: vibrancyEffect)
        visualEffectView.frame = view.bounds
        visualEffectView.autoresizingMask = view.autoresizingMask
        
        view.addSubview(visualEffectView)
        
        let loadingView: UIView = {
            var frame: CGRect = self.view.frame;
            frame.origin.x = 0;
            frame.origin.y = 0;
            
            let view = UIView(frame: frame)
            view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
            view.backgroundColor = .clearColor()
            
            return view
        }()
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleBottomMargin]
        activityIndicator.center = view.center
        loadingView.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
        let containerStackView: UIStackView! = {
            let stack = UIStackView()
            stack.axis = .Horizontal
            stack.distribution = .FillEqually
            stack.alignment = .Fill
            stack.spacing = 3.0
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Vertical)
            return stack
        }()
        
        let activeSiteLabel: UILabel = UILabel(frame: CGRectMake(10, 2 , view.frame.size.width, 30))
        activeSiteLabel.text = NSLocalizedString("Active Site:", comment: "") + " " + sharedDefaults.stringForKey("activeSiteName")!
        activeSiteLabel.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        
        let salesLabel: UILabel = UILabel(frame: CGRectZero)
        salesLabel.numberOfLines = 0
        salesLabel.lineBreakMode = .ByWordWrapping
        let earningsLabel: UILabel = UILabel(frame: CGRectZero)
        earningsLabel.numberOfLines = 0
        earningsLabel.lineBreakMode = .ByWordWrapping
        
        salesLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        earningsLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        
        let salesString = NSMutableAttributedString()
        let earningsString = NSMutableAttributedString()
        let headingAttributes: [String: AnyObject] = [
            NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        ]
        
        let textAttributes: [String: AnyObject] = [
            NSFontAttributeName: UIFont.systemFontOfSize(40, weight: UIFontWeightLight)
        ]
        
        containerStackView.addArrangedSubview(salesLabel)
        containerStackView.addArrangedSubview(earningsLabel)
        
        visualEffectView.contentView.addSubview(containerStackView)
        visualEffectView.contentView.addSubview(activeSiteLabel)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(containerStackView.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: 30))
        constraints.append(containerStackView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -10))
        constraints.append(containerStackView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: 10))
        constraints.append(containerStackView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor, constant: -10))
        
        NSLayoutConstraint.activateConstraints(constraints)
        
        visualEffectView.contentView.addSubview(loadingView)
        
        guard let defaultSite = sharedDefaults.objectForKey("defaultSite") as? String else {
            return
        }

        let auth = SSKeychain.accountsForService(defaultSite)
        let data = auth[0] as NSDictionary
        let acct = data.objectForKey("acct") as! String
        let password = SSKeychain.passwordForService(defaultSite, account: acct)
        
        let siteURL = sharedDefaults.stringForKey("activeSiteURL")! + "/edd-api/v2/stats"
        
        let parameters = ["key": acct, "token": password]
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.currencyCode = sharedDefaults.stringForKey("activeSiteCurrency")!
        
        Alamofire.request(.GET, siteURL, parameters: parameters)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                if response.result.isSuccess {
                    let resJSON = JSON(response.result.value!)
                    loadingView.removeFromSuperview()
                    
                    let salesHeadingString = NSAttributedString(string: NSLocalizedString("Today's Sales", comment: "") + "\n", attributes: headingAttributes)
                    salesString.appendAttributedString(salesHeadingString)
                    
                    let salesStatString = NSAttributedString(string: resJSON["stats"]["sales"]["today"].stringValue, attributes: textAttributes)
                    salesString.appendAttributedString(salesStatString)
                    
                    let earningsHeadingString = NSAttributedString(string: NSLocalizedString("Today's Earnings", comment: "") + "\n", attributes: headingAttributes)
                    earningsString.appendAttributedString(earningsHeadingString)
                    
                    let earningsStatString = NSAttributedString(string: formatter.stringFromNumber(resJSON["stats"]["earnings"]["today"].doubleValue)!, attributes: textAttributes)
                    earningsString.appendAttributedString(earningsStatString)

                    salesLabel.attributedText = salesString
                    earningsLabel.attributedText = earningsString
                }
                
                if response.result.isFailure {
                    let error: NSError = response.result.error!
                    print(error)
                }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.NewData)
    }
    
}
