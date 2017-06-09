//
//  SearchViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 29/08/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import SwiftyJSON
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


private let sharedDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
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
        super.init(style: .plain)

        self.site = site

        title = NSLocalizedString("Search", comment: "Product Search View Controller title")
        tableView.isScrollEnabled = true
        tableView.bounces = true
        tableView.showsVerticalScrollIndicator = true
        tableView.isUserInteractionEnabled = true
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
            view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            view.backgroundColor = .EDDGreyColor()
            
            return view
        }()

        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        activityIndicator.center = view.center
        loadingView.addSubview(activityIndicator)

        activityIndicator.startAnimating()

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.barTintColor = .EDDBlackColor()
        searchController.searchBar.backgroundColor = .EDDBlackColor()
        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchBar.tintColor = .white
        searchController.searchBar.isTranslucent = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = NSLocalizedString("Search Products", comment: "")
        searchController.delegate = self
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        extendedLayoutIncludesOpaqueBars = true
        
        navigationController?.navigationBar.clipsToBounds = true
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        tableView.register(SearchTableViewCell.self, forCellReuseIdentifier: "SearchCell")
    
        for view in searchController.searchBar.subviews {
            for field in view.subviews {
                if field.isKind(of: UITextField.self) {
                    let textField: UITextField = field as! UITextField
                    textField.backgroundColor = .black
                    textField.textColor = .white
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchController.isActive = true
        DispatchQueue.main.async { 
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func showNoResultsView() {
        noResultsView = {
            var frame: CGRect = self.view.frame;
            frame.origin.x = 0;
            frame.origin.y = 0;
            
            let view = UIView(frame: frame)
            view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            view.backgroundColor = .EDDGreyColor()
            
            return view
        }()
        
        let noResultsLabel = UILabel()
        noResultsLabel.text = NSLocalizedString("No Products Found.", comment: "")
        noResultsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        noResultsLabel.textAlignment = .center
        noResultsLabel.sizeToFit()
        
        noResultsView.addSubview(noResultsLabel)
        view.addSubview(noResultsView)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(noResultsLabel.widthAnchor.constraint(equalTo: view.widthAnchor))
        constraints.append(noResultsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return filteredTableData.count
        } else {
            return 0
        }
    }
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.filteredTableData[indexPath.row]
        
        var stats: Data?
        if Site.hasPermissionToViewReports() {
            stats = NSKeyedArchiver.archivedData(withRootObject: item["stats"].dictionaryObject!)
        } else {
            stats = nil
        }
        
        var files: Data?
        var notes: String?
        if Site.hasPermissionToViewSensitiveData() {
            if item["files"].arrayObject != nil {
                files = NSKeyedArchiver.archivedData(withRootObject: item["files"].arrayObject!)
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
        
        let pricing = NSKeyedArchiver.archivedData(withRootObject: item["pricing"].dictionaryObject!)
        
        let product = Product.objectForData(AppDelegate.sharedInstance.managedObjectContext, content: item["info"]["content"].stringValue, createdDate: sharedDateFormatter.date(from: item["info"]["create_date"].stringValue)!, files: files, hasVariablePricing: hasVariablePricing as NSNumber, link: item["info"]["link"].stringValue, modifiedDate: sharedDateFormatter.date(from: item["info"]["modified_date"].stringValue)!, notes: notes, pid: item["info"]["id"].int64Value, pricing: pricing, stats: stats, status: item["info"]["status"].stringValue, thumbnail: item["info"]["thumbnail"].stringValue, title: item["info"]["title"].stringValue, licensing: item["licensing"].dictionary as [String : AnyObject]?)
        
        navigationController?.pushViewController(ProductsDetailViewController(product: product), animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchTableViewCell
        
        cell.configureForObject(filteredTableData[indexPath.row])
        
        return cell
    }
    
}

extension SearchViewController: UISearchControllerDelegate {
    
    // MARK: UISearchControllerDelegate
    
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    
    // MARK: UISearchBar Delegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.addSubview(loadingView)
        
        self.filteredTableData.removeAll(keepingCapacity: false)
        
        let searchTerms = searchBar.text
        if searchTerms?.characters.count > 0 {
            let encodedSearchTerms = searchTerms!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            EDDAPIWrapper.sharedInstance.requestProducts(["s" : encodedSearchTerms! as AnyObject], success: { (json) in
                if let items = json["products"].array {
                    DispatchQueue.main.async(execute: {
                        self.loadingView.removeFromSuperview()
                    })
                    if items.count == 0 {
                        DispatchQueue.main.async(execute: {
                            self.showNoResultsView()
                        })
                    } else {
                        DispatchQueue.main.async(execute: {
                            self.noResultsView.removeFromSuperview()
                        })
                        for item in items {
                            self.filteredTableData.append(item)
                            DispatchQueue.main.async(execute: {
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
