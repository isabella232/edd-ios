//
//  NewSiteViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 22/08/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON
import SSKeychain
import SafariServices

class NewSiteViewController: UIViewController, UITextFieldDelegate, ManagedObjectContextSettable {

    var managedObjectContext: NSManagedObjectContext!
    var site: Site!
    
    let sharedDefaults: NSUserDefaults = NSUserDefaults(suiteName: "group.easydigitaldownloads.EDDSalesTracker")!
    
    let containerView = UIView()
    let stackView = UIStackView()
    
    let logo = UIImageView(image: UIImage(named: "EDDLogoText-White"))
    let mascot = UIImageView(image: UIImage(named: "EDDMascot"))
    let helpButton = UIButton(type: .Custom)
    let closeButton = UIButton(type: .Custom)
    let siteName = LoginTextField()
    let siteURL = LoginTextField()
    let apiKey = LoginTextField()
    let token = LoginTextField()
    let connectionTest = UILabel()
    
    let addButton = LoginSubmitButton()
    
    var yOffset: CGFloat = 0
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.appearance()
        
        let textFields = [siteName, siteURL, apiKey, token]
        
        var index = 0;
        
        logo.transform = CGAffineTransformMakeTranslation(0, -200)
        closeButton.transform = CGAffineTransformMakeTranslation(-200, 0)
        helpButton.transform = CGAffineTransformMakeTranslation(200, 0)
        addButton.layer.opacity = 0
        
        UIView.animateWithDuration(1.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
            self.logo.transform = CGAffineTransformMakeTranslation(0, 0);
            self.closeButton.transform = CGAffineTransformMakeTranslation(0, 0)
            self.helpButton.transform = CGAffineTransformMakeTranslation(0, 0)
            }, completion: nil)
        
        for field in textFields {
            let field: LoginTextField = field as LoginTextField
            field.layer.opacity = 0
            field.transform = CGAffineTransformMakeTranslation(0, 50)
            UIView.animateWithDuration(1.5, delay: 0.1 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                field.transform = CGAffineTransformMakeTranslation(0, 0);
                field.layer.opacity = 1
                }, completion: nil)
            index += 1
        }
        
        UIView.animateWithDuration(1.0, delay: 0.6, options: [], animations: {
            self.addButton.layer.opacity = 1
            }, completion: nil)
        
        // Keyboard observers
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewSiteViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewSiteViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: self.view.window)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.bounds = view.bounds
        containerView.frame = view.frame
        containerView.backgroundColor = .clearColor()
        
        logo.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin]
        logo.contentMode = .ScaleAspectFit
        logo.heightAnchor.constraintEqualToConstant(100).active = true
        
        helpButton.accessibilityLabel = NSLocalizedString("Help", comment: "Help button")
        helpButton.addTarget(self, action: #selector(NewSiteViewController.handleHelpButtonTapped(_:)), forControlEvents: .TouchUpInside)
        helpButton.setImage(UIImage(named: "Help"), forState: .Normal)
        helpButton.translatesAutoresizingMaskIntoConstraints = false
        helpButton.contentMode = .ScaleAspectFit
        helpButton.sizeToFit()
        
        closeButton.accessibilityLabel = NSLocalizedString("Close", comment: "Close button")
        closeButton.addTarget(self, action: #selector(NewSiteViewController.handleCloseButtonTapped(_:)), forControlEvents: .TouchUpInside)
        closeButton.setImage(UIImage(named: "Close"), forState: .Normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.contentMode = .ScaleAspectFit
        closeButton.sizeToFit()

        siteName.tag = 1
        siteName.placeholder = NSLocalizedString("Site Name", comment: "")
        siteName.delegate = self
        siteName.accessibilityIdentifier = "Site Name"
        
        siteURL.tag = 2
        siteURL.placeholder = NSLocalizedString("Site URL", comment: "")
        siteURL.delegate = self
        siteURL.accessibilityIdentifier = "Site URL"
        siteURL.autocapitalizationType = .None
        siteURL.keyboardType = .URL
        
        apiKey.tag = 3
        apiKey.placeholder = NSLocalizedString("API Key", comment: "")
        apiKey.delegate = self
        apiKey.accessibilityIdentifier = "API Key"
        apiKey.autocapitalizationType = .None
        
        token.tag = 4
        token.placeholder = NSLocalizedString("Token", comment: "")
        token.delegate = self
        token.accessibilityIdentifier = "Token"
        
        addButton.addTarget(self, action: #selector(NewSiteViewController.addButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        addButton.setTitle("Add Site", forState: UIControlState.Normal)
        addButton.setTitleColor(.whiteColor(), forState: UIControlState.Normal)
        addButton.setTitleColor(.whiteColor(), forState: UIControlState.Highlighted)
        addButton.backgroundColor = .EDDBlueColor()
        addButton.layer.cornerRadius = 2
        addButton.layer.opacity = 0.3
        addButton.clipsToBounds = true
        addButton.enabled = false
        
        connectionTest.textColor = .whiteColor()
        connectionTest.text = "Connecting to " + siteName.text! + "..."
        connectionTest.textAlignment = .Center
        connectionTest.hidden = true
        
        let buttonSpacerView = UIView()
        buttonSpacerView.heightAnchor.constraintEqualToConstant(20).active = true
        
        let labelSpacerView = UIView()
        labelSpacerView.heightAnchor.constraintEqualToConstant(20).active = true
        
        stackView.axis = .Vertical
        stackView.distribution = .Fill
        stackView.alignment = .Fill
        stackView.spacing = 0
        
        stackView.addArrangedSubview(logo)
        stackView.addArrangedSubview(siteName)
        stackView.addArrangedSubview(siteURL)
        stackView.addArrangedSubview(apiKey)
        stackView.addArrangedSubview(token)
        stackView.addArrangedSubview(buttonSpacerView)
        stackView.addArrangedSubview(addButton)
        stackView.addArrangedSubview(labelSpacerView)
        stackView.addArrangedSubview(connectionTest)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.layoutMarginsRelativeArrangement = true
        
        mascot.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mascot)
        view.addConstraints([NSLayoutConstraint(item: mascot, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0)])
        view.addConstraints([NSLayoutConstraint(item: mascot, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: -16)])
        
        containerView.addSubview(stackView)
        view.addSubview(containerView)
        
        view.addSubview(helpButton)
        view.addSubview(closeButton)
        helpButton.widthAnchor.constraintEqualToConstant(20).active = true
        helpButton.heightAnchor.constraintEqualToConstant(20).active = true
        closeButton.widthAnchor.constraintEqualToConstant(20).active = true
        closeButton.heightAnchor.constraintEqualToConstant(20).active = true
        
        let margins = view.layoutMarginsGuide
        helpButton.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor, constant: 8).active = true
        helpButton.trailingAnchor.constraintEqualToAnchor(margins.trailingAnchor).active = true
        closeButton.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor, constant: 8).active = true
        closeButton.leadingAnchor.constraintEqualToAnchor(margins.leadingAnchor).active = true

        
        stackView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        stackView.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor).active = true
        stackView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: 25).active = true
        stackView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor, constant: -25).active = true
        
        yOffset = self.containerView.center.y
    }
    
    func fillInFields(components: [NSURLQueryItem]) {
        for item in components {
            if item.name == "siteurl" {
                siteURL.text = item.value
            }
            
            if item.name == "sitename" {
                siteName.text = item.value
            }
            
            if item.name == "key" {
                apiKey.text = item.value
            }
            
            if item.name == "token" {
                token.text = item.value
            }
            
        }
    }
    
    func appearance() {
        view.backgroundColor = UIColor.EDDBlackColor()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 5 || textField.tag == 6 {
            return false
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        validateInputs()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let textField = textField as! LoginTextField
        
        guard ( textField.tag == 2 && canOpenURL(textField.text) ) ||
            ( textField.tag != 2 && textField.hasText() ) else {
                textField.validated(false)
                return
        }
        
        textField.validated(true)
        
        validateInputs()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        guard let nextResponder: UIResponder = (textField.superview?.viewWithTag(nextTag)) else {
            textField.resignFirstResponder()
            return true
        }
        
        if nextResponder.canBecomeFirstResponder() && nextTag < 5 {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func validateInputs() {
        if siteName.hasText() && siteURL.hasText() && canOpenURL(siteURL.text) && apiKey.hasText() && token.hasText() {
            UIView.animateWithDuration(0.5, animations: {
                self.addButton.layer.opacity = 1
                self.addButton.enabled = true
            })
        } else {
            UIView.animateWithDuration(0.5, animations: {
                self.addButton.layer.opacity = 0.3
                self.addButton.enabled = false
            })
        }
    }
    
    // MARK: Button Handlers
    
    func handleHelpButtonTapped(sender: UIButton) {
        let svc = SFSafariViewController(URL: NSURL(string: "http://docs.easydigitaldownloads.com/article/1134-edd-rest-api---authentication")!)
        if #available(iOS 10.0, *) {
            svc.preferredBarTintColor = .EDDBlackColor()
            svc.preferredControlTintColor = .whiteColor()
        } else {
            svc.view.tintColor = .EDDBlueColor()
        }
        svc.modalPresentationStyle = .OverCurrentContext
        presentViewController(svc, animated: true, completion: nil)
    }
    
    func handleCloseButtonTapped(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addButtonPressed(sender: UIButton!) {
        let button = sender as! LoginSubmitButton
        button.showActivityIndicator(true)
        
        connectionTest.text = "Connecting to " + siteName.text! + "..."
        
        let textFields = [siteName, siteURL, apiKey, token]
        
        for textField in textFields {
            textField.enabled = false
        }
        
        self.addButton.enabled = false
        
        UIView.animateWithDuration(0.5) {
            self.siteName.layer.opacity = 0.3
            self.siteURL.layer.opacity = 0.3
            self.apiKey.layer.opacity = 0.3
            self.token.layer.opacity = 0.3
            
            self.connectionTest.hidden = false
        }
        
        Alamofire.request(.GET, siteURL.text! + "/edd-api/info", parameters: ["key": apiKey.text!, "token": token.text!])
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .Success:
                    let json = JSON(response.result.value!)
                    
                    if json["info"] != nil {
                        let info = json["info"]
                        let integrations = info["integrations"]
                        let currency = "\(info["site"]["currency"])"
                        let permissions: NSData = NSKeyedArchiver.archivedDataWithRootObject(info["permissions"].dictionaryObject!)
                        let uid = NSUUID().UUIDString
                        let appDelegate = AppDelegate()
                        
                        self.connectionTest.text = NSLocalizedString("Connection successful", comment: "")
                        
                        var hasReviews = false
                        var hasCommissions = false
                        var hasFES = false
                        var hasRecurring = false
                        var hasLicensing = false
                        
                        for (key, value) : (String, JSON) in integrations {
                            if key == "reviews" && value.boolValue == true {
                                hasReviews = true
                            }
                            
                            if key == "commissions" && value.boolValue == true {
                                hasCommissions = true
                            }
                            
                            if key == "software_licensing" && value.boolValue == true {
                                hasLicensing = true
                            }
                            
                            if key == "fes" && value.boolValue == true {
                                hasFES = true
                            }
                            
                            if key == "recurring" && value.boolValue == true {
                                hasRecurring = true
                            }
                        }
                        
                        SSKeychain.setPassword(self.token.text, forService: uid, account: self.apiKey.text)
                        
                        // Only set the defaultSite if this is the first site being added
                        self.sharedDefaults.setValue(uid, forKey: "defaultSite")
                        self.sharedDefaults.setValue(uid, forKey: "activeSite")
                        self.sharedDefaults.setValue(self.siteName.text!, forKey: "activeSiteName")
                        self.sharedDefaults.setValue(currency, forKey: "activeSiteCurrency")
                        self.sharedDefaults.setValue(self.siteURL.text!, forKey: "activeSiteURL")
                        self.sharedDefaults.synchronize()
                        
                        AppDelegate.sharedInstance.switchActiveSite(uid)
                        
                        // Create the dashboard layout based on the permissions granted
                        let dashboardLayout: NSMutableArray = [1, 2];
                        if hasCommissions {
                            dashboardLayout.addObject(3);
                        }
                        
                        if hasRecurring {
                            dashboardLayout.addObject(4);
                        }
                        
                        let dashboardOrder: NSData = NSKeyedArchiver.archivedDataWithRootObject(dashboardLayout);
                        
                        var site: Site?
                        
                        self.managedObjectContext.performChanges {
                            site = Site.insertIntoContext(self.managedObjectContext, uid: uid, name: self.siteName.text!, url: self.siteURL.text!, currency: currency, hasCommissions: hasCommissions, hasFES: hasFES, hasRecurring: hasRecurring, hasReviews: hasReviews, hasLicensing: hasLicensing, permissions: permissions, dashboardOrder: dashboardOrder);
                            self.managedObjectContext.performSaveOrRollback()
                        }
                        
                        UIView.animateWithDuration(1.0, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                            self.logo.transform = CGAffineTransformMakeTranslation(0, -400)
                            self.addButton.transform = CGAffineTransformMakeTranslation(0, self.view.bounds.height)
                            self.helpButton.transform = CGAffineTransformMakeTranslation(200, 0)
                            self.connectionTest.transform = CGAffineTransformMakeTranslation(0, self.view.bounds.height)
                            for field in textFields {
                                field.transform = CGAffineTransformMakeTranslation(0, self.view.bounds.height)
                            }
                            }, completion: { (finished: Bool) -> Void in
                                let tabBarController = SiteTabBarController(site: site!)
                                tabBarController.modalPresentationStyle = .OverCurrentContext
                                self.presentViewController(tabBarController, animated: true, completion:nil)
                        })
                    }
                    break;
                case .Failure(let error):
                    NSLog(error.localizedDescription)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.connectionTest.text = NSLocalizedString("Connection failed", comment: "")
                        for textField in textFields {
                            textField.enabled = true
                            textField.layer.opacity = 1
                        }
                        
                        button.showActivityIndicator(false)
                    })
                    break;
                }
        }
    }
    
    // MARK: Validation
    
    func canOpenURL(string: String?) -> Bool {
        // Initial (basic) validation
        guard let urlString = string?.stringByRemovingPercentEncoding! else {
            return false
        }
        
        guard let url = NSURL(string: urlString) else {
            return false
        }
        
        if !UIApplication.sharedApplication().canOpenURL(url) {
            return false
        }
        
        // Regex validation
        let regEx = "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        return NSPredicate(format: "SELF MATCHES %@", regEx).evaluateWithObject(urlString)
    }
    
    // MARK: Keyboard Handlers
    
    func keyboardWillShow(notification: NSNotification) {
        if view.frame.origin.y == 0  {
            stackView.center.y = yOffset - 100
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        stackView.center.y = yOffset
    }

}
