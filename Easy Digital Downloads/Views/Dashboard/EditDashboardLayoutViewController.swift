//
//  EditDashboardLayoutViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 04/07/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

class EditDashboardLayoutViewController: UIViewController {

    private var tableView: UITableView!
    private var navigationBar: UINavigationBar!
    private var site: Site!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    init(site: Site) {
        self.site = site
        
        super.init(nibName: nil, bundle: nil)
        
        navigationBar = UINavigationBar(frame: CGRectMake(0, 0, view.frame.width, 64))
        tableView = UITableView(frame: CGRectMake(0, 0, view.frame.width, view.frame.height - navigationBar.frame.height) ,style: .Plain);
        
        let navigationItem = UINavigationItem(title: NSLocalizedString("Edit Dashboard", comment: ""))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(EditDashboardLayoutViewController.doneButtonPressed(_:)))
        navigationItem.rightBarButtonItem = doneButton
        navigationBar.items = [navigationItem]
        
        title = NSLocalizedString("Edit Dashboard", comment: "")
        
        view.addSubview(navigationBar)
        view.addSubview(tableView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func doneButtonPressed(sender: UIButton!) {
        
    }

}
