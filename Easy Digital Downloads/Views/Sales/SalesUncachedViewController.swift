//
//  SalesUncachedViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 16/10/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import AlamofireImage
import SwiftyJSON
import Haneke

private let sharedDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}()

class SalesUncachedViewController: SiteTableViewController {

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
    var id: Int64!
    var sale: Sales!
    var products: [JSON]!
    var licenses: [JSON]?
    var customer: JSON?
    var operation: Bool = false
    
    var loadingView = UIView()
    
    init(id: Int64) {
        super.init(style: .plain)
        
        self.site = Site.activeSite()
        self.id = id
        
        view.backgroundColor = .EDDGreyColor()
        
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
        
        networkOperations()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        
        title = NSLocalizedString("Fetching Sale...", comment: "")
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(NSLocalizedString("Fetching Sale...", comment: ""))
        navigationItem.titleView = titleLabel
        
        tableView.register(SalesDetailMetaTableViewCell.self, forCellReuseIdentifier: "SalesDetailMetaTableViewCell")
        tableView.register(SalesDetailHeadingTableViewCell.self, forCellReuseIdentifier: "SalesDetailHeadingTableViewCell")
        tableView.register(SalesDetailProductTableViewCell.self, forCellReuseIdentifier: "SalesDetailProductTableViewCell")
        tableView.register(SalesDetailCustomerTableViewCell.self, forCellReuseIdentifier: "SalesDetailCustomerTableViewCell")
        tableView.register(SalesDetailLicensesTableViewCell.self, forCellReuseIdentifier: "SalesDetailLicensesTableViewCell")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Private
    
    fileprivate func networkOperations() {
        self.operation = true
        view.addSubview(loadingView)
        
        EDDAPIWrapper.sharedInstance.requestSales(["id" : "\(id)"], success: { (json) in
            if let items = json["sales"].array {
                let item = items[0]
                
                self.sale = Sales(ID: item["ID"].int64Value, transactionId: item["transaction_id"].string, key: item["key"].string, subtotal: item["subtotal"].doubleValue, tax: item["tax"].double, fees: item["fees"].array, total: item["total"].doubleValue, gateway: item["gateway"].stringValue, email: item["email"].stringValue, date: sharedDateFormatter.dateFromString(item["date"].stringValue), discounts: item["discounts"].dictionary, products: item["products"].arrayValue, licenses: item["licenses"].array)
                
                self.operation = true
                
                self.cells = [.Meta, .ProductsHeading]
                
                EDDAPIWrapper.sharedInstance.requestCustomers(["customer": self.sale.email], success: { json in
                    let items = json["customers"].arrayValue
                    self.customer = items[0]
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                }) { (error) in
                    print(error.localizedDescription)
                }
                
                if self.sale.products!.count == 1 {
                    self.cells.append(.Product)
                } else {
                    for _ in 1...self.sale.products!.count {
                        self.cells.append(.Product)
                    }
                }
                
                if let items = self.sale.products {
                    self.products = [JSON]()
                    for item in items {
                        self.products.append(item)
                    }
                }
                
                self.cells.append(.CustomerHeading)
                self.cells.append(.Customer)
                
                if self.sale.licenses != nil {
                    self.cells.append(.LicensesHeading)
                    
                    if self.sale.licenses!.count == 1 {
                        self.cells.append(.License)
                    } else {
                        self.licenses = [JSON]()
                        for _ in 1...self.sale.licenses!.count {
                            self.cells.append(.License)
                        }
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    let titleLabel = ViewControllerTitleLabel()
                    titleLabel.setTitle("Sale #\(self.sale.ID)")
                    self.navigationItem.titleView = titleLabel
                    
                    self.operation = false
                    self.loadingView.removeFromSuperview()
                    self.tableView.reloadData()
                })
            }
            }) { (error) in
                NSLog(error.localizedDescription)
        }
        
    }
    
    // MARK: Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.operation ? 0 : cells.count
    }
    
    // MARK: Table View Delegate
    
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if cells[indexPath.row] == CellType.customer {
            guard let item = customer else {
                return
            }
            let customerObject = Customer.objectForData(AppDelegate.sharedInstance.managedObjectContext, displayName: item["info"]["display_name"].stringValue, email: item["info"]["email"].stringValue, firstName: item["info"]["first_name"].stringValue, lastName: item["info"]["last_name"].stringValue, totalDownloads: item["stats"]["total_downloads"].int64Value, totalPurchases: item["stats"]["total_purchases"].int64Value, totalSpent: item["stats"]["total_spent"].doubleValue, uid: item["info"]["customer_id"].int64Value, username: item["username"].stringValue, dateCreated: sharedDateFormatter.dateFromString(item["info"]["date_created"].stringValue)!)
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

}
