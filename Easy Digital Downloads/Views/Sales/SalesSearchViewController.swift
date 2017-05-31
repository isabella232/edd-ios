//
//  SalesSearchViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 16/10/2016.
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

class SalesSearchViewController: SiteTableViewController {

    fileprivate enum CellType {
        case meta
        case productsHeading
        case product
        case customerHeading
        case customer
        case licensesHeading
        case license
    }
    
    typealias JSON = SwiftyJSON.JSON
    
    fileprivate var cells = [CellType]()
    
    var site: Site?
    var sale: Sales!
    var products: [JSON]!
    var licenses: [JSON]?
    var customer: JSON?
    
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
        
        tableView.register(SalesDetailMetaTableViewCell.self, forCellReuseIdentifier: "SalesDetailMetaTableViewCell")
        tableView.register(SalesDetailHeadingTableViewCell.self, forCellReuseIdentifier: "SalesDetailHeadingTableViewCell")
        tableView.register(SalesDetailProductTableViewCell.self, forCellReuseIdentifier: "SalesDetailProductTableViewCell")
        tableView.register(SalesDetailCustomerTableViewCell.self, forCellReuseIdentifier: "SalesDetailCustomerTableViewCell")
        tableView.register(SalesDetailLicensesTableViewCell.self, forCellReuseIdentifier: "SalesDetailLicensesTableViewCell")
        
        cells = [.meta, .productsHeading]
        
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
        searchController.searchBar.placeholder = NSLocalizedString("Enter Sale ID", comment: "")
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
        noResultsLabel.text = NSLocalizedString("Sale Not Found.", comment: "")
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
        if cells[indexPath.row] == CellType.customer {
            guard let item = customer else {
                return
            }
            let customerObject = Customer.objectForData(AppDelegate.sharedInstance.managedObjectContext, displayName: item["info"]["display_name"].stringValue, email: item["info"]["email"].stringValue, firstName: item["info"]["first_name"].stringValue, lastName: item["info"]["last_name"].stringValue, totalDownloads: item["stats"]["total_downloads"].int64Value, totalPurchases: item["stats"]["total_purchases"].int64Value, totalSpent: item["stats"]["total_spent"].doubleValue, uid: item["info"]["customer_id"].int64Value, username: item["username"].stringValue, dateCreated: sharedDateFormatter.date(from: item["info"]["date_created"].stringValue)!)
            navigationController?.pushViewController(CustomersDetailViewController(customer: customerObject), animated: true)
        }
        
        if cells[indexPath.row] == CellType.product {
            let product: JSON = sale.products[indexPath.row - 2]
            let id = product["id"].int64Value
            
            if let product = Product.productForId(id) {
                navigationController?.pushViewController(ProductsDetailViewController(product: product), animated: true)
            } else {
                navigationController?.pushViewController(ProductsOfflineViewController(id: id), animated: true)
            }
        }
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        switch cells[indexPath.row] {
        case .meta:
            cell = tableView.dequeueReusableCell(withIdentifier: "SalesDetailMetaTableViewCell", for: indexPath) as! SalesDetailMetaTableViewCell
            (cell as! SalesDetailMetaTableViewCell).configure(sale!)
        case .productsHeading:
            cell = tableView.dequeueReusableCell(withIdentifier: "SalesDetailHeadingTableViewCell", for: indexPath) as! SalesDetailHeadingTableViewCell
            (cell as! SalesDetailHeadingTableViewCell).configure("Products")
        case .product:
            cell = tableView.dequeueReusableCell(withIdentifier: "SalesDetailProductTableViewCell", for: indexPath) as! SalesDetailProductTableViewCell
            (cell as! SalesDetailProductTableViewCell).configure(sale.products[indexPath.row - 2])
        case .customerHeading:
            cell = tableView.dequeueReusableCell(withIdentifier: "SalesDetailHeadingTableViewCell", for: indexPath) as! SalesDetailHeadingTableViewCell
            (cell as! SalesDetailHeadingTableViewCell).configure("Customer")
        case .customer:
            cell = tableView.dequeueReusableCell(withIdentifier: "SalesDetailCustomerTableViewCell", for: indexPath) as! SalesDetailCustomerTableViewCell
            (cell as! SalesDetailCustomerTableViewCell).configure(customer)
        case .licensesHeading:
            cell = tableView.dequeueReusableCell(withIdentifier: "SalesDetailHeadingTableViewCell", for: indexPath) as! SalesDetailHeadingTableViewCell
            (cell as! SalesDetailHeadingTableViewCell).configure("Licenses")
        case .license:
            cell = tableView.dequeueReusableCell(withIdentifier: "SalesDetailLicensesTableViewCell", for: indexPath) as! SalesDetailLicensesTableViewCell
            (cell as! SalesDetailLicensesTableViewCell).configure(sale.licenses![indexPath.row - 5 - (products?.count)!])
        }
        
        return cell!
    }

}

extension SalesSearchViewController: UISearchControllerDelegate {
    
    // MARK: UISearchControllerDelegate
    
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
    
}

extension SalesSearchViewController: UISearchBarDelegate {
    
    // MARK: UISearchBar Delegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.addSubview(loadingView)
        
        self.filteredTableData.removeAll(keepingCapacity: false)
        
        let searchTerms = searchBar.text
        if searchTerms?.characters.count > 0 {
            let encodedSearchTerms = searchTerms!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            EDDAPIWrapper.sharedInstance.requestSales(["id" : encodedSearchTerms! as AnyObject], success: { (json) in
                if let items = json["sales"].array {
                    let item = items[0]
                    
                    DispatchQueue.main.async(execute: {
                        self.loadingView.removeFromSuperview()
                    })
                    if item["ID"].stringValue.characters.count == 0 {
                        DispatchQueue.main.async(execute: {
                            self.showNoResultsView()
                        })
                    } else {
                        let sale = Sales(ID: item["ID"].int64Value, transactionId: item["transaction_id"].string, key: item["key"].string, subtotal: item["subtotal"].doubleValue, tax: item["tax"].double, fees: item["fees"].array, total: item["total"].doubleValue, gateway: item["gateway"].stringValue, email: item["email"].stringValue, date: sharedDateFormatter.dateFromString(item["date"].stringValue), discounts: item["discounts"].dictionary, products: item["products"].arrayValue, licenses: item["licenses"].array)
                        
                        self.sale = sale
                        
                        if sale.products!.count == 1 {
                            self.cells.append(.product)
                        } else {
                            for _ in 1...sale.products!.count {
                                self.cells.append(.product)
                            }
                        }
                        
                        if let items = sale.products {
                            self.products = [JSON]()
                            for item in items {
                                self.products.append(item)
                            }
                        }
                        
                        self.cells.append(.customerHeading)
                        self.cells.append(.customer)
                        
                        if sale.licenses != nil {
                            self.cells.append(.licensesHeading)
                            
                            if sale.licenses!.count == 1 {
                                self.cells.append(.license)
                            } else {
                                self.licenses = [JSON]()
                                for _ in 1...sale.licenses!.count {
                                    self.cells.append(.license)
                                }
                            }
                        }
                        
                        DispatchQueue.main.async(execute: {
                            self.noResultsView.removeFromSuperview()
                            self.tableView.reloadData()
                        })
                        
                        EDDAPIWrapper.sharedInstance.requestCustomers(["customer": sale.email as AnyObject], success: { json in
                            let items = json["customers"].arrayValue
                            self.customer = items[0]
                            DispatchQueue.main.async(execute: {
                                self.tableView.reloadData()
                            })
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
