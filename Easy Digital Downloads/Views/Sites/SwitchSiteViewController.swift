//
//  SwitchSiteViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 17/07/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

class SwitchSiteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    fileprivate var tableView: UITableView!
    fileprivate var navigationBar: UINavigationBar!
    fileprivate var sites: [Site]?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sites = Site.fetchAll(inContext: AppDelegate.sharedInstance.managedObjectContext)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurEffect = UIBlurEffect(style: .dark)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.frame = view.bounds
        
        navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 64))
        navigationBar.isTranslucent = true
        navigationBar.barStyle = .blackTranslucent
        
        tableView = UITableView(frame: CGRect(x: 0, y: navigationBar.frame.height, width: view.frame.width, height: view.frame.height - navigationBar.frame.height) ,style: .plain);
        tableView.isScrollEnabled = true
        tableView.bounces = true
        tableView.showsVerticalScrollIndicator = true
        tableView.isUserInteractionEnabled = true
        tableView.backgroundColor = .clear
        tableView.separatorColor = UIColor.separatorColor()
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        
        let navigationItem = UINavigationItem(title: NSLocalizedString("Switch Site", comment: ""))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(SwitchSiteViewController.doneButtonPressed))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(SwitchSiteViewController.addButtonPressed))
        navigationItem.rightBarButtonItem = doneButton
        navigationItem.leftBarButtonItem = addButton
        navigationBar.items = [navigationItem]
        
        title = NSLocalizedString("Edit Dashboard", comment: "")
        
        view.addSubview(visualEffectView)
        view.addSubview(tableView)
        view.addSubview(navigationBar)
    }
    
    func doneButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    func addButtonPressed() {
        let newSiteViewController = NewSiteViewController()
        newSiteViewController.managedObjectContext = AppDelegate.sharedInstance.managedObjectContext
        newSiteViewController.view.backgroundColor = .clear
        newSiteViewController.modalPresentationStyle = .overFullScreen
        newSiteViewController.modalPresentationCapturesStatusBarAppearance = true
        present(newSiteViewController, animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    // MARK: Table View Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sites?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let site = sites![indexPath.row] as Site
        
        tableView.deselectRow(at: indexPath, animated: true)

        AppDelegate.sharedInstance.switchActiveSite(site.uid!)

        UIView.transition(with: self.view.window!, duration: 0.5, options: UIViewAnimationOptions.transitionFlipFromLeft, animations: {
            self.view.window?.rootViewController = SiteTabBarController(site: site)
            }, completion: nil)
    }
    
    // MARK: Table View Data Source
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "SwitchSiteCell")
        
        if (cell == nil) {
            cell = UITableViewCell(style: .default, reuseIdentifier: "SwitchSiteCell")
        }
        
        cell?.backgroundColor = UIColor.clear
        cell?.textLabel?.textColor = UIColor.white
        
        let site = sites![indexPath.row] as Site
        
        cell?.textLabel?.text = site.name!
        
        return cell!
    }
    
}
