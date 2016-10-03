//
//  TodayViewController.swift
//  Today
//
//  Created by Sunny Ratilal on 27/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import NotificationCenter
import Alamofire
import SSKeychain
import SwiftyJSON
import Haneke

class TodayViewController: UIViewController, NCWidgetProviding {
    
    let sharedDefaults: NSUserDefaults = NSUserDefaults(suiteName: "group.easydigitaldownloads.EDDSalesTracker")!
    
    typealias JSON = SwiftyJSON.JSON
    
    let sharedCache = Shared.dataCache
    var stats: JSON?
    
    let vibrancyEffect = UIVibrancyEffect.widgetPrimaryVibrancyEffect()
    var visualEffectView: UIVisualEffectView!
    
    lazy var containerStackView: UIStackView! = {
        let stack = UIStackView()
        stack.axis = .Horizontal
        stack.distribution = .FillEqually
        stack.alignment = .Fill
        stack.spacing = 3.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Vertical)
        return stack
    }()
    
    lazy var loadingView: UIView = {
        var frame: CGRect = self.view.frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        
        let view = UIView(frame: frame)
        view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        view.backgroundColor = .clearColor()
        
        return view
    }()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    let salesLabel: UILabel = UILabel(frame: CGRectZero)
    let earningsLabel: UILabel = UILabel(frame: CGRectZero)
    
    var salesString = NSMutableAttributedString()
    var earningsString = NSMutableAttributedString()
    let headingAttributes: [String: AnyObject] = [
        NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightBold)
    ]
    
    let textAttributes: [String: AnyObject] = [
        NSFontAttributeName: UIFont.systemFontOfSize(32, weight: UIFontWeightLight)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredContentSize = CGSizeMake(0, 200)
        
        visualEffectView = UIVisualEffectView(effect: vibrancyEffect)
        visualEffectView.frame = view.bounds
        visualEffectView.autoresizingMask = view.autoresizingMask
        
        view.addSubview(visualEffectView)
        
        activityIndicator.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleBottomMargin]
        activityIndicator.center = view.center
        loadingView.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TodayViewController.handleTap))
        gestureRecognizer.numberOfTapsRequired = 1
        containerStackView.addGestureRecognizer(gestureRecognizer)
        containerStackView.userInteractionEnabled = true
        
        let activeSiteLabel: UILabel = UILabel(frame: CGRectMake(10, 2 , view.frame.size.width, 30))
        activeSiteLabel.text = NSLocalizedString("Active Site:", comment: "") + " " + sharedDefaults.stringForKey("activeSiteName")!
        activeSiteLabel.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        
        salesLabel.numberOfLines = 0
        salesLabel.lineBreakMode = .ByWordWrapping
        earningsLabel.numberOfLines = 0
        earningsLabel.lineBreakMode = .ByWordWrapping
        
        salesLabel.font = UIFont.systemFontOfSize(14, weight: UIFontWeightBold)
        earningsLabel.font = UIFont.systemFontOfSize(14, weight: UIFontWeightBold)
        
        let salesHeadingString = NSAttributedString(string: NSLocalizedString("Today's Sales", comment: "") + "\n", attributes: self.headingAttributes)
        self.salesString.appendAttributedString(salesHeadingString)
        
        let earningsHeadingString = NSAttributedString(string: NSLocalizedString("Today's Earnings", comment: "") + "\n", attributes: self.headingAttributes)
        self.earningsString.appendAttributedString(earningsHeadingString)
        
        containerStackView.addArrangedSubview(salesLabel)
        containerStackView.addArrangedSubview(earningsLabel)
        
        visualEffectView.contentView.addSubview(containerStackView)
        visualEffectView.contentView.addSubview(activeSiteLabel)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(containerStackView.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: 20))
        constraints.append(containerStackView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -5))
        constraints.append(containerStackView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: 10))
        constraints.append(containerStackView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor, constant: -10))
        
        NSLayoutConstraint.activateConstraints(constraints)
        
        visualEffectView.contentView.addSubview(loadingView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        networkOperations()
    }
    
    func widgetPerformUpdate(completionHandler: ((NCUpdateResult) -> Void)) {
        guard let defaultSite = sharedDefaults.objectForKey("defaultSite") as? String else {
            completionHandler(.Failed)
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
                    
                    self.sharedCache.set(value: resJSON.asData(), key: defaultSite + "-TodayWidgetCachedData")
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.loadingView.removeFromSuperview()
                        
                        let salesHeadingString = NSAttributedString(string: NSLocalizedString("Today's Sales", comment: "") + "\n", attributes: self.headingAttributes)
                        self.salesString.appendAttributedString(salesHeadingString)
                        
                        let salesStatString = NSAttributedString(string: resJSON["stats"]["sales"]["today"].stringValue, attributes: self.textAttributes)
                        self.salesString.appendAttributedString(salesStatString)
                        
                        let earningsHeadingString = NSAttributedString(string: NSLocalizedString("Today's Earnings", comment: "") + "\n", attributes: self.headingAttributes)
                        self.earningsString.appendAttributedString(earningsHeadingString)
                        
                        let earningsStatString = NSAttributedString(string: formatter.stringFromNumber(resJSON["stats"]["earnings"]["today"].doubleValue)!, attributes: self.textAttributes)
                        self.earningsString.appendAttributedString(earningsStatString)
                        
                        self.salesLabel.attributedText = self.salesString
                        self.earningsLabel.attributedText = self.earningsString
                        
                        completionHandler(.NewData)
                    })
                }
                
                if response.result.isFailure {
                    completionHandler(.Failed)
                }
        }
    }
    
    func handleTap() {
        self.extensionContext?.openURL(NSURL(string: "edd://dashboard")!, completionHandler: nil)
    }
    
    private func networkOperations() {
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
                    
                    self.sharedCache.set(value: resJSON.asData(), key: defaultSite + "-TodayWidgetCachedData")
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.loadingView.removeFromSuperview()
                        
                        let salesHeadingString = NSAttributedString(string: NSLocalizedString("Today's Sales", comment: "") + "\n", attributes: self.headingAttributes)
                        self.salesString = salesHeadingString.mutableCopy() as! NSMutableAttributedString
                        
                        let earningsHeadingString = NSAttributedString(string: NSLocalizedString("Today's Earnings", comment: "") + "\n", attributes: self.headingAttributes)
                        self.earningsString = earningsHeadingString.mutableCopy() as! NSMutableAttributedString
                        
                        let salesStatString = NSAttributedString(string: resJSON["stats"]["sales"]["today"].stringValue, attributes: self.textAttributes)
                        self.salesString.appendAttributedString(salesStatString)
                        
                        let earningsStatString = NSAttributedString(string: formatter.stringFromNumber(resJSON["stats"]["earnings"]["today"].doubleValue)!, attributes: self.textAttributes)
                        self.earningsString.appendAttributedString(earningsStatString)
                        
                        self.salesLabel.attributedText = self.salesString
                        self.earningsLabel.attributedText = self.earningsString
                    })
                }
                
                if response.result.isFailure {
                }
        }

    }
    
}
