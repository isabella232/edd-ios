//
//  CustomersSearchViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 16/10/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import SwiftyJSON

private let sharedDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}()

class CustomersSearchViewController: SiteTableViewController {

    fileprivate enum CellType {
        case profile
        case stats
        case salesHeading
        case sales
        case subscriptionsHeading
        case subscriptions
    }
    
    typealias JSON = SwiftyJSON.JSON
    
    fileprivate var cells = [CellType]()
    
    var site: Site?
    var customer: Customer?
    var recentSales: [JSON]?
    var recentSubscriptions: [JSON]?
    
    var filteredTableData = [JSON]()
    
    let searchController = SearchController(searchResultsController: nil)
    
    var loadingView = UIView()
    var noResultsView = UIView()
    
    init() {
        super.init(style: .plain)
        
        self.site = Site.activeSite()
        
        title = NSLocalizedString("Search", comment: "Sales Search View Controller title")
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
        titleLabel.setTitle(NSLocalizedString("Search", comment: "Sales Search View Controller title"))
        navigationItem.titleView = titleLabel
        
        tableView.register(CustomerProfileTableViewCell.self, forCellReuseIdentifier: "CustomerProfileTableViewCell")
        tableView.register(CustomerStatsTableViewCell.self, forCellReuseIdentifier: "CustomerStatsTableViewCell")
        tableView.register(CustomerDetailHeadingTableViewCell.self, forCellReuseIdentifier: "CustomerHeadingTableViewCell")
        tableView.register(CustomerRecentSaleTableViewCell.self, forCellReuseIdentifier: "CustomerRecentSaleTableViewCell")
        tableView.register(CustomerDetailSubscriptionTableViewCell.self, forCellReuseIdentifier: "CustomerSubscriptionTableViewCell")
        
        cells = [.profile, .stats]
        
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
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.placeholder = NSLocalizedString("Enter Customer ID/Email Address", comment: "")
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
        noResultsLabel.text = NSLocalizedString("Customer Not Found.", comment: "")
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
            return cells.count
        } else {
            return 0
        }
    }
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if cells[indexPath.row] == CellType.sales {
            var offset = 0
            if cells[2] == CellType.subscriptionsHeading {
                offset = indexPath.row - (recentSubscriptions?.count)! - 4
                
            } else {
                offset = indexPath.row - 3
            }
            
            let item = recentSales![offset]
            
            let sale = Sales(ID: item["ID"].int64Value, transactionId: item["transaction_id"].stringValue, key: item["key"].stringValue, subtotal: item["subtotal"].doubleValue, tax: item["tax"].double, fees: item["fees"].array, total: item["total"].doubleValue, gateway: item["gateway"].stringValue, email: item["email"].stringValue, date: sharedDateFormatter.dateFromString(item["date"].stringValue), discounts: item["discounts"].dictionary, products: item["products"].arrayValue, licenses: item["licenses"].array)
            
            navigationController?.pushViewController(SalesDetailViewController(sale: sale), animated: true)
        }
        
        if cells[indexPath.row] == CellType.subscriptions {
            var offset = 0
            if cells[2] == CellType.salesHeading {
                offset = indexPath.row - (recentSales?.count)! - 4
                
            } else {
                offset = indexPath.row - 3
            }
            
            let item = recentSubscriptions![offset]
            
            let subscription = Subscriptions(ID: item["info"]["id"].int64Value, customerId: item["info"]["customer_id"].int64Value, period: item["info"]["period"].stringValue, initialAmount: item["info"]["initial_amount"].doubleValue, recurringAmount: item["info"]["recurring_amount"].doubleValue, billTimes: item["info"]["bill_times"].int64Value, transactionId: item["info"]["transaction_id"].stringValue, parentPaymentId: item["info"]["parent_payment_id"].int64Value, productId: item["info"]["product_id"].int64Value, created: sharedDateFormatter.dateFromString(item["info"]["created"].stringValue), expiration: sharedDateFormatter.dateFromString(item["info"]["expiration"].stringValue), status: item["info"]["status"].stringValue, profileId: item["info"]["profile_id"].stringValue, gateway: item["info"]["gateway"].stringValue, customer: item["info"]["customer"].dictionaryValue, renewalPayments: item["payments"].array)
            
            navigationController?.pushViewController(SubscriptionsDetailViewController(subscription: subscription), animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        switch(cells[indexPath.row]) {
            case .profile:
                cell = tableView.dequeueReusableCell(withIdentifier: "CustomerProfileTableViewCell", for: indexPath) as! CustomerProfileTableViewCell
                (cell as! CustomerProfileTableViewCell).configure(customer!)
            case .stats:
                cell = tableView.dequeueReusableCell(withIdentifier: "CustomerStatsTableViewCell", for: indexPath) as! CustomerStatsTableViewCell
                (cell as! CustomerStatsTableViewCell).configure(customer!)
            case .salesHeading:
                cell = tableView.dequeueReusableCell(withIdentifier: "CustomerHeadingTableViewCell", for: indexPath) as! CustomerDetailHeadingTableViewCell
                (cell as! CustomerDetailHeadingTableViewCell).configure("Recent Sales")
            case .sales:
                cell = tableView.dequeueReusableCell(withIdentifier: "CustomerRecentSaleTableViewCell", for: indexPath) as! CustomerRecentSaleTableViewCell
                var offset = 0
                if cells[2] == CellType.subscriptionsHeading {
                    offset = indexPath.row - (recentSubscriptions?.count)! - 4
                    
                } else {
                    offset = indexPath.row - 3
                }
                (cell as! CustomerRecentSaleTableViewCell).configure(recentSales![offset])
            case .subscriptionsHeading:
                cell = tableView.dequeueReusableCell(withIdentifier: "CustomerHeadingTableViewCell", for: indexPath) as! CustomerDetailHeadingTableViewCell
                (cell as! CustomerDetailHeadingTableViewCell).configure("Recent Subscriptions")
            case .subscriptions:
                cell = tableView.dequeueReusableCell(withIdentifier: "CustomerSubscriptionTableViewCell", for: indexPath) as! CustomerDetailSubscriptionTableViewCell
                var offset = 0
                if cells[2] == CellType.salesHeading {
                    offset = indexPath.row - (recentSales?.count)! - 4
                    
                } else {
                    offset = indexPath.row - 3
                }
                (cell as! CustomerDetailSubscriptionTableViewCell).configure(recentSubscriptions![offset])
        }
        
        return cell!
    }

}

extension CustomersSearchViewController: UISearchControllerDelegate {
    
    // MARK: UISearchControllerDelegate
    
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
    
}

extension CustomersSearchViewController: UISearchBarDelegate {
    
    // MARK: UISearchBar Delegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.addSubview(loadingView)
        
        self.filteredTableData.removeAll(keepCapacity: false)
        
        let searchTerms = searchBar.text!
        if searchTerms.characters.count > 0 {
            EDDAPIWrapper.sharedInstance.requestCustomers(["customer" : searchTerms], success: { (json) in
                if let error = json["error"].string {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.showNoResultsView()
                    })
                }

                if let items = json["customers"].array {
                    let item = items[0]
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.loadingView.removeFromSuperview()
                    })
                    
                    let customer = Customer.objectForData(AppDelegate.sharedInstance.managedObjectContext, displayName: item["info"]["display_name"].stringValue, email: item["info"]["email"].stringValue, firstName: item["info"]["first_name"].stringValue, lastName: item["info"]["last_name"].stringValue, totalDownloads: item["stats"]["total_downloads"].int64Value, totalPurchases: item["stats"]["total_purchases"].int64Value, totalSpent: item["stats"]["total_spent"].doubleValue, uid: item["info"]["customer_id"].int64Value, username: item["username"].stringValue, dateCreated: sharedDateFormatter.dateFromString(item["info"]["date_created"].stringValue)!)
                    
                    self.customer = customer
                    
                    dispatch_async(dispatch_get_main_queue(), { 
                        self.tableView.reloadData()
                    })
                    
                    EDDAPIWrapper.sharedInstance.requestSales(["email" : customer.email], success: { (json) in
                        if let items = json["sales"].array {
                            self.cells.append(.SalesHeading)
                            self.recentSales = items
                            for _ in 1...items.count {
                                self.cells.append(.Sales)
                            }
                            dispatch_async(dispatch_get_main_queue(), {
                                self.tableView.reloadData()
                            })
                        }
                    }) { (error) in
                        print(error.localizedDescription)
                    }
                    
                    if (Site.activeSite().hasRecurring != nil) {
                        EDDAPIWrapper.sharedInstance.requestSubscriptions(["customer" : customer.email], success: { (json) in
                            if let items = json["subscriptions"].array {
                                self.cells.append(.SubscriptionsHeading)
                                self.recentSubscriptions = items
                                for _ in 1...items.count {
                                    self.cells.append(.Subscriptions)
                                }
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.tableView.reloadData()
                                })
                            }
                        }) { (error) in
                            print(error.localizedDescription)
                        }
                    }
                }
            }, failure: { (error) in
                print(error.localizedDescription)
            })
        }
    }
    
}
