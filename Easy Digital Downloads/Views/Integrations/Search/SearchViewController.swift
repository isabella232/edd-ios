//
//  SearchViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 29/08/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import SwiftyJSON

private let sharedDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}()

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
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(NSLocalizedString("Search", comment: "Product Search View Controller title"))
        navigationItem.titleView = titleLabel

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
        searchController.delegate = self
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        extendedLayoutIncludesOpaqueBars = true
        
        navigationController?.navigationBar.clipsToBounds = true
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        
        tableView.registerClass(SearchTableViewCell.self, forCellReuseIdentifier: "SearchCell")
    
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        searchController.active = true
        dispatch_async(dispatch_get_main_queue()) { 
            self.searchController.searchBar.becomeFirstResponder()
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = self.filteredTableData[indexPath.row]
        
        var stats: NSData?
        if Site.hasPermissionToViewReports() {
            stats = NSKeyedArchiver.archivedDataWithRootObject(item["stats"].dictionaryObject!)
        } else {
            stats = nil
        }
        
        var files: NSData?
        var notes: String?
        if Site.hasPermissionToViewSensitiveData() {
            if item["files"].arrayObject != nil {
                files = NSKeyedArchiver.archivedDataWithRootObject(item["files"].arrayObject!)
            } else {
                files = nil
            }
            
            notes = item["notes"].stringValue
        } else {
            files = nil
            notes = nil
        }
        
        var hasVariablePricing = false
        if item["pricing"].dictionary?.count > 1 {
            hasVariablePricing = true
        }
        
        let pricing = NSKeyedArchiver.archivedDataWithRootObject(item["pricing"].dictionaryObject!)
        
        let product = Product.objectForData(AppDelegate.sharedInstance.managedObjectContext, content: item["info"]["content"].stringValue, createdDate: sharedDateFormatter.dateFromString(item["info"]["create_date"].stringValue)!, files: files, hasVariablePricing: hasVariablePricing, link: item["info"]["link"].stringValue, modifiedDate: sharedDateFormatter.dateFromString(item["info"]["modified_date"].stringValue)!, notes: notes, pid: item["info"]["id"].int64Value, pricing: pricing, stats: stats, status: item["info"]["status"].stringValue, thumbnail: item["info"]["thumbnail"].stringValue, title: item["info"]["title"].stringValue, licensing: item["licensing"].dictionaryObject)
        
        navigationController?.pushViewController(ProductsDetailViewController(product: product), animated: true)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchCell", forIndexPath: indexPath) as! SearchTableViewCell
        
        cell.configureForObject(filteredTableData[indexPath.row])
        
        return cell
    }
    
}

extension SearchViewController: UISearchControllerDelegate {
    
    // MARK: UISearchControllerDelegate
    
    func didPresentSearchController(searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    
    // MARK: UISearchBar Delegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        view.addSubview(loadingView)
        
        self.filteredTableData.removeAll(keepCapacity: false)
        
        let searchTerms = searchBar.text
        if searchTerms?.characters.count > 0 {
            let encodedSearchTerms = searchTerms!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
            EDDAPIWrapper.sharedInstance.requestProducts(["s" : encodedSearchTerms!], success: { (json) in
                if let items = json["products"].array {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.loadingView.removeFromSuperview()
                    })
                    if items.count == 0 {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.showNoResultsView()
                        })
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.noResultsView.removeFromSuperview()
                        })
                        for item in items {
                            self.filteredTableData.append(item)
                            dispatch_async(dispatch_get_main_queue(), {
                                self.tableView.reloadData()
                            })
                        }
                    }
                }
                }, failure: { (error) in
                    print(error.localizedDescription)
            })
        }
    }
    
}