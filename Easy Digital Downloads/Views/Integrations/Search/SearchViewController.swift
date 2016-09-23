//
//  SearchViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 29/08/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import SwiftyJSON

class SearchViewController: SiteTableViewController {

    var site: Site?
    
    var filteredTableData = [JSON]()
    
    let searchController = SearchController(searchResultsController: nil)
    
    var loadingView = UIView()
    var noResultsView = UIView()
    
    init(site: Site) {
        super.init(style: .Plain)
        
        self.site = site
        
        title = NSLocalizedString("Search", comment: "Product Search View Controller title")
        tableView.scrollEnabled = true
        tableView.bounces = true
        tableView.showsVerticalScrollIndicator = true
        tableView.userInteractionEnabled = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = estimatedHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        
        loadingView = {
            var frame: CGRect = self.view.frame;
            frame.origin.x = 0;
            frame.origin.y = 0;
            
            let view = UIView(frame: frame)
            view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
            view.backgroundColor = .EDDGreyColor()
            
            return view
        }()
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleBottomMargin]
        activityIndicator.center = view.center
        loadingView.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.barTintColor = .EDDBlackColor()
        searchController.searchBar.backgroundColor = .EDDBlackColor()
        searchController.searchBar.searchBarStyle = .Prominent
        searchController.searchBar.tintColor = .whiteColor()
        searchController.searchBar.translucent = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = NSLocalizedString("Search Products", comment: "")
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        for view in searchController.searchBar.subviews {
            for field in view.subviews {
                if field.isKindOfClass(UITextField.self) {
                    let textField: UITextField = field as! UITextField
                    textField.backgroundColor = .blackColor()
                    textField.textColor = .whiteColor()
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func showNoResultsView() {
        noResultsView = {
            var frame: CGRect = self.view.frame;
            frame.origin.x = 0;
            frame.origin.y = 0;
            
            let view = UIView(frame: frame)
            view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
            view.backgroundColor = .EDDGreyColor()
            
            return view
        }()
        
        let noResultsLabel = UILabel()
        noResultsLabel.text = NSLocalizedString("No Products Found.", comment: "")
        noResultsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        noResultsLabel.textAlignment = .Center
        noResultsLabel.sizeToFit()
        
        noResultsView.addSubview(noResultsLabel)
        view.addSubview(noResultsView)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(noResultsLabel.widthAnchor.constraintEqualToAnchor(view.widthAnchor))
        constraints.append(noResultsLabel.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor))
        
        NSLayoutConstraint.activateConstraints(constraints)
    }
    
    // MARK: Table View Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active {
            return filteredTableData.count
        } else {
            return 0
        }
    }
    
    // MARK: Table View Delegate
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchCell", forIndexPath: indexPath)
        
//        cell.textLabel?.text = filteredTableData[indexPath.row]
        
        return cell
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    
    // MARK: UISearchBar Delegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        view.addSubview(loadingView)
        let searchTerms = searchBar.text
        if searchTerms?.characters.count > 0 {
            let encodedSearchTerms = searchTerms!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
            EDDAPIWrapper.sharedInstance.requestProducts(["s" : encodedSearchTerms!], success: { (json) in
                if let items = json["products"].array {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.loadingView.removeFromSuperview()
                    })
                    if items.count == 0 {
                        self.showNoResultsView()
                    } else {
                        for item in items {
                            self.filteredTableData.append(item)
                            dispatch_async(dispatch_get_main_queue(), {
                                self.tableView.reloadData()
                            })
                        }
                    }
                }
                }, failure: { (error) in
                    fatalError()
            })
        }
    }
    
}
