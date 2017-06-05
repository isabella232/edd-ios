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
import SAMKeychain
import SwiftyJSON
import Haneke

class TodayViewController: UIViewController, NCWidgetProviding {
    
    let sharedDefaults: UserDefaults = UserDefaults(suiteName: "group.easydigitaldownloads.EDDSalesTracker")!
    
    typealias JSON = SwiftyJSON.JSON
    
    let sharedCache = Shared.dataCache
    var stats: JSON?
    
    let vibrancyEffect = UIVibrancyEffect.widgetPrimary()
    var visualEffectView: UIVisualEffectView!
    
    lazy var containerStackView: UIStackView! = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.spacing = 3.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        return stack
    }()
    
    lazy var loadingView: UIView = {
        var frame: CGRect = self.view.frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        
        let view = UIView(frame: frame)
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.backgroundColor = .clear
        
        return view
    }()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    let salesLabel: UILabel = UILabel(frame: CGRect.zero)
    let earningsLabel: UILabel = UILabel(frame: CGRect.zero)
    
    var salesString = NSMutableAttributedString()
    var earningsString = NSMutableAttributedString()
    let headingAttributes: [String: AnyObject] = [
        NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightBold)
    ]
    
    let textAttributes: [String: AnyObject] = [
        NSFontAttributeName: UIFont.systemFont(ofSize: 32, weight: UIFontWeightLight)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredContentSize = CGSize(width: 0, height: 200)
        
        visualEffectView = UIVisualEffectView(effect: vibrancyEffect)
        visualEffectView.frame = view.bounds
        visualEffectView.autoresizingMask = view.autoresizingMask
        
        view.addSubview(visualEffectView)
        
        activityIndicator.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        activityIndicator.center = view.center
        loadingView.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TodayViewController.handleTap))
        gestureRecognizer.numberOfTapsRequired = 1
        containerStackView.addGestureRecognizer(gestureRecognizer)
        containerStackView.isUserInteractionEnabled = true
        
        let activeSiteLabel: UILabel = UILabel(frame: CGRect(x: 10, y: 2 , width: view.frame.size.width, height: 30))
        activeSiteLabel.text = NSLocalizedString("Active Site:", comment: "") + " " + sharedDefaults.string(forKey: "activeSiteName")!
        activeSiteLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight)
        
        salesLabel.numberOfLines = 0
        salesLabel.lineBreakMode = .byWordWrapping
        earningsLabel.numberOfLines = 0
        earningsLabel.lineBreakMode = .byWordWrapping
        
        salesLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightBold)
        earningsLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightBold)
        
        let salesHeadingString = NSAttributedString(string: NSLocalizedString("Today's Sales", comment: "") + "\n", attributes: self.headingAttributes)
        self.salesString.append(salesHeadingString)
        
        let earningsHeadingString = NSAttributedString(string: NSLocalizedString("Today's Earnings", comment: "") + "\n", attributes: self.headingAttributes)
        self.earningsString.append(earningsHeadingString)
        
        containerStackView.addArrangedSubview(salesLabel)
        containerStackView.addArrangedSubview(earningsLabel)
        
        visualEffectView.contentView.addSubview(containerStackView)
        visualEffectView.contentView.addSubview(activeSiteLabel)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(containerStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20))
        constraints.append(containerStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5))
        constraints.append(containerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10))
        constraints.append(containerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10))
        
        NSLayoutConstraint.activate(constraints)
        
        visualEffectView.contentView.addSubview(loadingView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        networkOperations()
    }
    
    func widgetPerformUpdate(_ completionHandler: @escaping ((NCUpdateResult) -> Void)) {
        guard let defaultSite = sharedDefaults.object(forKey: "defaultSite") as? String else {
            completionHandler(.failed)
            return
        }
        
        let auth = SAMKeychain.accounts(forService: defaultSite)
        let data = auth![0] as NSDictionary
        let acct = data.object(forKey: "acct") as! String
        let password = SAMKeychain.password(forService: defaultSite, account: acct)
        
        let siteURL = sharedDefaults.string(forKey: "activeSiteURL")! + "/edd-api/v2/stats"
        
        let parameters : Parameters = ["key": acct, "token": password!]

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = sharedDefaults.string(forKey: "activeSiteCurrency")!
        
        Alamofire.request(siteURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                if response.result.isSuccess {
                    let resJSON = JSON(response.result.value!)
                    
                    self.sharedCache.set(value: resJSON.asData(), key: defaultSite + "-TodayWidgetCachedData")
                    
                    DispatchQueue.main.async(execute: {
                        self.loadingView.removeFromSuperview()
                        
                        let salesHeadingString = NSAttributedString(string: NSLocalizedString("Today's Sales", comment: "") + "\n", attributes: self.headingAttributes)
                        self.salesString.append(salesHeadingString)
                        
                        let salesStatString = NSAttributedString(string: resJSON["stats"]["sales"]["today"].stringValue, attributes: self.textAttributes)
                        self.salesString.append(salesStatString)
                        
                        let earningsHeadingString = NSAttributedString(string: NSLocalizedString("Today's Earnings", comment: "") + "\n", attributes: self.headingAttributes)
                        self.earningsString.append(earningsHeadingString)
                        
                        let earningsStatString = NSAttributedString(string: formatter.string(from: NSNumber(value: resJSON["stats"]["earnings"]["today"].doubleValue))!, attributes: self.textAttributes)
                        self.earningsString.append(earningsStatString)
                        
                        self.salesLabel.attributedText = self.salesString
                        self.earningsLabel.attributedText = self.earningsString
                        
                        completionHandler(.newData)
                    })
                }
                
                if response.result.isFailure {
                    completionHandler(.failed)
                }
        }
    }
    
    func handleTap() {
        self.extensionContext?.open(URL(string: "edd://dashboard")!, completionHandler: nil)
    }
    
    fileprivate func networkOperations() {
        guard let defaultSite = sharedDefaults.object(forKey: "defaultSite") as? String else {
            return
        }
        
        let auth = SAMKeychain.accounts(forService: defaultSite)
        let data = auth![0] as NSDictionary
        let acct = data.object(forKey: "acct") as! String
        let password = SAMKeychain.password(forService: defaultSite, account: acct)
        
        let siteURL = sharedDefaults.string(forKey: "activeSiteURL")! + "/edd-api/v2/stats"
        
        let parameters : Parameters = ["key": acct, "token": password!]
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = sharedDefaults.string(forKey: "activeSiteCurrency")!
        
        Alamofire.request(siteURL, method: .get, parameters: parameters)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                if response.result.isSuccess {
                    let resJSON = JSON(response.result.value!)
                    
                    self.sharedCache.set(value: resJSON.asData(), key: defaultSite + "-TodayWidgetCachedData")
                    
                    DispatchQueue.main.async(execute: {
                        self.loadingView.removeFromSuperview()
                        
                        let salesHeadingString = NSAttributedString(string: NSLocalizedString("Today's Sales", comment: "") + "\n", attributes: self.headingAttributes)
                        self.salesString = salesHeadingString.mutableCopy() as! NSMutableAttributedString
                        
                        let earningsHeadingString = NSAttributedString(string: NSLocalizedString("Today's Earnings", comment: "") + "\n", attributes: self.headingAttributes)
                        self.earningsString = earningsHeadingString.mutableCopy() as! NSMutableAttributedString
                        
                        let salesStatString = NSAttributedString(string: resJSON["stats"]["sales"]["today"].stringValue, attributes: self.textAttributes)
                        self.salesString.append(salesStatString)

                        let earningsStatString = NSAttributedString(string: formatter.string(from: NSNumber(value: resJSON["stats"]["earnings"]["today"].doubleValue))!, attributes: self.textAttributes)
                        
                        self.earningsString.append(earningsStatString)
                        
                        self.salesLabel.attributedText = self.salesString
                        self.earningsLabel.attributedText = self.earningsString
                    })
                }
                
                if response.result.isFailure {
                }
        }

    }
    
}
