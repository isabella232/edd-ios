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
import SAMKeychain
import SafariServices

class NewSiteViewController: UIViewController, UITextFieldDelegate, ManagedObjectContextSettable {

    var managedObjectContext: NSManagedObjectContext!
    var site: Site!
    
    let sharedDefaults: UserDefaults = UserDefaults(suiteName: "group.easydigitaldownloads.EDDSalesTracker")!
    
    let containerView = UIView()
    let stackView = UIStackView()
    
    let logo = UIImageView(image: UIImage(named: "EDDLogoText-White"))
    let mascot = UIImageView(image: UIImage(named: "EDDMascot"))
    let helpButton = UIButton(type: .custom)
    let closeButton = UIButton(type: .custom)
    let siteName = LoginTextField()
    let siteURL = LoginTextField()
    let apiKey = LoginTextField()
    let token = LoginTextField()
    let connectionTest = UILabel()
    
    let addButton = LoginSubmitButton()
    
    var yOffset: CGFloat = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.appearance()
        
        self.managedObjectContext = AppDelegate.sharedInstance.managedObjectContext
        
        let textFields = [siteName, siteURL, apiKey, token]
        
        var index = 0;
        
        logo.transform = CGAffineTransform(translationX: 0, y: -200)
        closeButton.transform = CGAffineTransform(translationX: -200, y: 0)
        helpButton.transform = CGAffineTransform(translationX: 200, y: 0)
        addButton.layer.opacity = 0
        
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
            self.logo.transform = CGAffineTransform(translationX: 0, y: 0);
            self.closeButton.transform = CGAffineTransform(translationX: 0, y: 0)
            self.helpButton.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: nil)
        
        for field in textFields {
            let field: LoginTextField = field as LoginTextField
            field.layer.opacity = 0
            field.transform = CGAffineTransform(translationX: 0, y: 50)
            UIView.animate(withDuration: 1.5, delay: 0.1 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                field.transform = CGAffineTransform(translationX: 0, y: 0);
                field.layer.opacity = 1
                }, completion: nil)
            index += 1
        }
        
        UIView.animate(withDuration: 1.0, delay: 0.6, options: [], animations: {
            self.addButton.layer.opacity = 1
            }, completion: nil)
        
        // Keyboard observers
        NotificationCenter.default.addObserver(self, selector: #selector(NewSiteViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(NewSiteViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.bounds = view.bounds
        containerView.frame = view.frame
        containerView.backgroundColor = .clear
        
        logo.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        logo.contentMode = .scaleAspectFit
        logo.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        helpButton.accessibilityLabel = NSLocalizedString("Help", comment: "Help button")
        helpButton.addTarget(self, action: #selector(NewSiteViewController.handleHelpButtonTapped(_:)), for: .touchUpInside)
        helpButton.setImage(UIImage(named: "Help"), for: UIControlState())
        helpButton.translatesAutoresizingMaskIntoConstraints = false
        helpButton.contentMode = .scaleAspectFit
        helpButton.sizeToFit()
        
        closeButton.accessibilityLabel = NSLocalizedString("Close", comment: "Close button")
        closeButton.addTarget(self, action: #selector(NewSiteViewController.handleCloseButtonTapped(_:)), for: .touchUpInside)
        closeButton.setImage(UIImage(named: "Close"), for: UIControlState())
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.contentMode = .scaleAspectFit
        closeButton.sizeToFit()

        siteName.tag = 1
        siteName.placeholder = NSLocalizedString("Site Name", comment: "")
        siteName.delegate = self
        siteName.accessibilityIdentifier = "Site Name"
        
        siteURL.tag = 2
        siteURL.placeholder = NSLocalizedString("Site URL", comment: "")
        siteURL.delegate = self
        siteURL.accessibilityIdentifier = "Site URL"
        siteURL.autocapitalizationType = .none
        siteURL.keyboardType = .URL
        
        apiKey.tag = 3
        apiKey.placeholder = NSLocalizedString("API Key", comment: "")
        apiKey.delegate = self
        apiKey.accessibilityIdentifier = "API Key"
        apiKey.autocapitalizationType = .none
        
        token.tag = 4
        token.placeholder = NSLocalizedString("Token", comment: "")
        token.delegate = self
        token.accessibilityIdentifier = "Token"
        
        addButton.addTarget(self, action: #selector(NewSiteViewController.addButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        addButton.setTitle("Add Site", for: UIControlState())
        addButton.setTitleColor(.white, for: UIControlState())
        addButton.setTitleColor(.white, for: UIControlState.highlighted)
        addButton.backgroundColor = .EDDBlueColor()
        addButton.layer.cornerRadius = 2
        addButton.layer.opacity = 0.3
        addButton.clipsToBounds = true
        addButton.isEnabled = false
        
        connectionTest.textColor = .white
        connectionTest.text = "Connecting to " + siteName.text! + "..."
        connectionTest.textAlignment = .center
        connectionTest.isHidden = true
        connectionTest.numberOfLines = 0
        connectionTest.lineBreakMode = .byWordWrapping
        
        let buttonSpacerView = UIView()
        buttonSpacerView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        let labelSpacerView = UIView()
        labelSpacerView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
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
        
        stackView.isLayoutMarginsRelativeArrangement = true
        
        mascot.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mascot)
        view.addConstraints([NSLayoutConstraint(item: mascot, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)])
        view.addConstraints([NSLayoutConstraint(item: mascot, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -16)])
        
        containerView.addSubview(stackView)
        view.addSubview(containerView)
        
        view.addSubview(helpButton)
        view.addSubview(closeButton)
        helpButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        helpButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        let margins = view.layoutMarginsGuide
        helpButton.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 8).isActive = true
        helpButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        closeButton.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 8).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true

        
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25).isActive = true
        
        yOffset = self.containerView.center.y
    }
    
    func fillInFields(_ components: [URLQueryItem]) {
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
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 5 || textField.tag == 6 {
            return false
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        validateInputs()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let textField = textField as! LoginTextField
        
        guard ( textField.tag == 2 && canOpenURL(textField.text) ) ||
            ( textField.tag != 2 && textField.hasText ) else {
                textField.validated(false)
                return
        }
        
        textField.validated(true)
        
        validateInputs()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        guard let nextResponder: UIResponder = (textField.superview?.viewWithTag(nextTag)) else {
            textField.resignFirstResponder()
            return true
        }
        
        if nextResponder.canBecomeFirstResponder && nextTag < 5 {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func validateInputs() {
        if siteName.hasText && siteURL.hasText && canOpenURL(siteURL.text) && apiKey.hasText && token.hasText {
            UIView.animate(withDuration: 0.5, animations: {
                self.addButton.layer.opacity = 1
                self.addButton.isEnabled = true
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.addButton.layer.opacity = 0.3
                self.addButton.isEnabled = false
            })
        }
    }
    
    // MARK: Button Handlers
    
    func handleHelpButtonTapped(_ sender: UIButton) {
        let svc = SFSafariViewController(url: URL(string: "http://docs.easydigitaldownloads.com/article/1469-site-setup")!)
        if #available(iOS 10.0, *) {
            svc.preferredBarTintColor = .EDDBlackColor()
            svc.preferredControlTintColor = .white
        } else {
            svc.view.tintColor = .EDDBlueColor()
        }
        svc.modalPresentationStyle = .overCurrentContext
        present(svc, animated: true, completion: nil)
    }
    
    func handleCloseButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func addButtonPressed(_ sender: UIButton!) {
        let button = sender as! LoginSubmitButton
        button.showActivityIndicator(true)
        
        connectionTest.text = "Connecting to " + siteName.text! + "..."
        
        let textFields = [siteName, siteURL, apiKey, token]
        
        for textField in textFields {
            textField.isEnabled = false
        }
        
        self.addButton.isEnabled = false
        
        UIView.animate(withDuration: 0.5, animations: {
            self.siteName.layer.opacity = 0.3
            self.siteURL.layer.opacity = 0.3
            self.apiKey.layer.opacity = 0.3
            self.token.layer.opacity = 0.3
            
            self.connectionTest.isHidden = false
        }) 
        
        Alamofire.request(siteURL.text! + "/edd-api/info", method: .get, parameters: ["key": apiKey.text!, "token": token.text!], encoding: URLEncoding.default, headers: nil)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success( _):
                    let json = JSON(response.result.value!)
                    
                    if json["info"] != JSON.null {
                        let info = json["info"]
                        let integrations = info["integrations"]
                        let currency = "\(info["site"]["currency"])"
                        let permissions: NSData = NSKeyedArchiver.archivedData(withRootObject: info["permissions"].dictionaryObject!) as NSData
                        let uid = NSUUID().uuidString
                        
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
                        
                        if (SAMKeychain.setPassword(self.token.text!, forService: uid, account: self.apiKey.text!) == true) {
                            // Only set the defaultSite if this is the first site being added
                            self.sharedDefaults.setValue(uid, forKey: "defaultSite")
                            self.sharedDefaults.setValue(uid, forKey: "activeSite")
                            self.sharedDefaults.setValue(self.siteName.text!, forKey: "activeSiteName")
                            self.sharedDefaults.setValue(currency, forKey: "activeSiteCurrency")
                            self.sharedDefaults.setValue(self.siteURL.text!, forKey: "activeSiteURL")
                            self.sharedDefaults.synchronize()
                            
                            // Create the dashboard layout based on the permissions granted
                            let dashboardLayout: NSMutableArray = [1, 2];
                            if hasCommissions {
                                dashboardLayout.add(3);
                            }
                            
                            if hasRecurring {
                                dashboardLayout.add(4);
                            }
                            
                            let dashboardOrder: NSData = NSKeyedArchiver.archivedData(withRootObject: dashboardLayout) as NSData;
                            
                            var site: Site?
                            
                            self.managedObjectContext.performChanges {
                                site = Site.insertIntoContext(self.managedObjectContext, uid: uid, name: self.siteName.text!, url: self.siteURL.text!, currency: currency, hasCommissions: hasCommissions, hasFES: hasFES, hasRecurring: hasRecurring, hasReviews: hasReviews, hasLicensing: hasLicensing, permissions: permissions as Data, dashboardOrder: dashboardOrder as Data);
                                self.managedObjectContext.performSaveOrRollback()
                            }
                            
                            UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                                self.logo.transform = CGAffineTransform(translationX: 0, y: -400)
                                self.addButton.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
                                self.helpButton.transform = CGAffineTransform(translationX: 200, y: 0)
                                self.connectionTest.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
                                for field in textFields {
                                    field.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
                                }
                                }, completion: { (finished: Bool) -> Void in
                                    AppDelegate.sharedInstance.switchActiveSite(site!.uid!)
                                    EDDAPIWrapper.sharedInstance.refreshActiveSite()
                                    let tabBarController = SiteTabBarController(site: site!)
                                    tabBarController.modalPresentationStyle = .overCurrentContext
                                    self.present(tabBarController, animated: true, completion:nil)
                            })
                        }
                    }
                    break;
                case .failure(let error):
                    DispatchQueue.main.async(execute: {
                        self.connectionTest.text = NSLocalizedString("Connection failed.", comment: "") + " " + error.localizedDescription
                        for textField in textFields {
                            textField.isEnabled = true
                            textField.layer.opacity = 1
                        }
                        
                        button.showActivityIndicator(false)
                    })
                    break;
                }
        }
    }
    
    // MARK: Validation
    
    func canOpenURL(_ string: String?) -> Bool {
        // Initial (basic) validation
        guard let urlString = string?.removingPercentEncoding! else {
            return false
        }
        
        guard let url = URL(string: urlString) else {
            return false
        }
        
        if !UIApplication.shared.canOpenURL(url) {
            return false
        }
        
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: urlString, options: [], range: NSRange(location: 0, length: urlString.utf16.count)) {
            if (match.resultType == NSTextCheckingResult.CheckingType.link) {
                return true;
            }
        }
        
        return false;
    }
    
    // MARK: Keyboard Handlers
    
    func keyboardWillShow(_ notification: Notification) {
        if view.frame.origin.y == 0  {
            stackView.center.y = yOffset - 100
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        stackView.center.y = yOffset
    }

}
