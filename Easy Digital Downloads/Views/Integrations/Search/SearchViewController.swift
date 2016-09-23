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
    
    var filteredTableData = [String]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var loadingView = UIView()
    
    init(site: Site) {
        super.init(style: .Plain)
        
        self.site = site
        
        title = NSLocalizedString("Product Search", comment: "Product Search View Controller title")
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
        searchController.searchBar.tintColor = .tableViewCellHighlightColor()
        searchController.searchBar.translucent = false
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
        
        cell.textLabel?.text = filteredTableData[indexPath.row]
        
        return cell
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    
    // MARK: - UISearchBar Delegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        view.addSubview(loadingView)
        let searchTerms = searchBar.text
        if searchTerms?.characters.count > 0 {
            let encodedSearchTerms = searchTerms!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
            EDDAPIWrapper.sharedInstance.requestProducts(["s" : encodedSearchTerms!], success: { (json) in
                print(json)
                }, failure: { (error) in
                    fatalError()
            })
        }
    }
    
}
