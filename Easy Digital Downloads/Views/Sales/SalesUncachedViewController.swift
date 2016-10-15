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

private let sharedDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}()

class SalesUncachedViewController: SiteTableViewController {

    private enum CellType {
        case Meta
        case ProductsHeading
        case Product
        case CustomerHeading
        case Customer
        case LicensesHeading
        case License
    }
    
    typealias JSON = SwiftyJSON.JSON
    
    private var cells = [CellType]()
    
    var site: Site?
    var id: Int64!
    var sale: Sales!
    var products: [JSON]!
    var licenses: [JSON]?
    var customer: JSON?
    var operation: Bool = false
    
    var loadingView = UIView()
    
    init(id: Int64) {
        super.init(style: .Plain)
        
        self.site = Site.activeSite()
        self.id = id
        
        view.backgroundColor = .EDDGreyColor()
        
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
        
        networkOperations()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
        
        title = NSLocalizedString("Fetching Sale...", comment: "")
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(NSLocalizedString("Fetching Sale...", comment: ""))
        navigationItem.titleView = titleLabel
        
        tableView.registerClass(SalesDetailMetaTableViewCell.self, forCellReuseIdentifier: "SalesDetailMetaTableViewCell")
        tableView.registerClass(SalesDetailHeadingTableViewCell.self, forCellReuseIdentifier: "SalesDetailHeadingTableViewCell")
        tableView.registerClass(SalesDetailProductTableViewCell.self, forCellReuseIdentifier: "SalesDetailProductTableViewCell")
        tableView.registerClass(SalesDetailCustomerTableViewCell.self, forCellReuseIdentifier: "SalesDetailCustomerTableViewCell")
        tableView.registerClass(SalesDetailLicensesTableViewCell.self, forCellReuseIdentifier: "SalesDetailLicensesTableViewCell")
        
        cells = [.Meta, .ProductsHeading]
        
        EDDAPIWrapper.sharedInstance.requestCustomers(["customer": sale.email], success: { json in
            let items = json["customers"].arrayValue
            self.customer = items[0]
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }) { (error) in
            print(error.localizedDescription)
        }
        
        if sale.products!.count == 1 {
            cells.append(.Product)
        } else {
            for _ in 1...sale.products!.count {
                cells.append(.Product)
            }
        }
        
        if let items = sale.products {
            products = [JSON]()
            for item in items {
                products.append(item)
            }
        }
        
        cells.append(.CustomerHeading)
        cells.append(.Customer)
        
        if sale.licenses != nil {
            cells.append(.LicensesHeading)
            
            if sale.licenses!.count == 1 {
                cells.append(.License)
            } else {
                licenses = [JSON]()
                for _ in 1...sale.licenses!.count {
                    cells.append(.License)
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Private
    
    private func networkOperations() {
        self.operation = true
        view.addSubview(loadingView)
        
        EDDAPIWrapper.sharedInstance.requestSales(["id" : "\(id)"], success: { (json) in
            if let items = json["sales"].array {
                let item = items[0]
                
                self.sale = Sales(ID: item["ID"].int64Value, transactionId: item["transaction_id"].string, key: item["key"].string, subtotal: item["subtotal"].doubleValue, tax: item["tax"].double, fees: item["fees"].array, total: item["total"].doubleValue, gateway: item["gateway"].stringValue, email: item["email"].stringValue, date: sharedDateFormatter.dateFromString(item["date"].stringValue), discounts: item["discounts"].dictionary, products: item["products"].arrayValue, licenses: item["licenses"].array)
                
                self.operation = true
                
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
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.operation ? 0 : cells.count
    }
    
    // MARK: Table View Delegate
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        switch cells[indexPath.row] {
        case .Meta:
            cell = tableView.dequeueReusableCellWithIdentifier("SalesDetailMetaTableViewCell", forIndexPath: indexPath) as! SalesDetailMetaTableViewCell
            (cell as! SalesDetailMetaTableViewCell).configure(sale!)
        case .ProductsHeading:
            cell = tableView.dequeueReusableCellWithIdentifier("SalesDetailHeadingTableViewCell", forIndexPath: indexPath) as! SalesDetailHeadingTableViewCell
            (cell as! SalesDetailHeadingTableViewCell).configure("Products")
        case .Product:
            cell = tableView.dequeueReusableCellWithIdentifier("SalesDetailProductTableViewCell", forIndexPath: indexPath) as! SalesDetailProductTableViewCell
            (cell as! SalesDetailProductTableViewCell).configure(sale.products[indexPath.row - 2])
        case .CustomerHeading:
            cell = tableView.dequeueReusableCellWithIdentifier("SalesDetailHeadingTableViewCell", forIndexPath: indexPath) as! SalesDetailHeadingTableViewCell
            (cell as! SalesDetailHeadingTableViewCell).configure("Customer")
        case .Customer:
            cell = tableView.dequeueReusableCellWithIdentifier("SalesDetailCustomerTableViewCell", forIndexPath: indexPath) as! SalesDetailCustomerTableViewCell
            (cell as! SalesDetailCustomerTableViewCell).configure(customer)
        case .LicensesHeading:
            cell = tableView.dequeueReusableCellWithIdentifier("SalesDetailHeadingTableViewCell", forIndexPath: indexPath) as! SalesDetailHeadingTableViewCell
            (cell as! SalesDetailHeadingTableViewCell).configure("Licenses")
        case .License:
            cell = tableView.dequeueReusableCellWithIdentifier("SalesDetailLicensesTableViewCell", forIndexPath: indexPath) as! SalesDetailLicensesTableViewCell
            (cell as! SalesDetailLicensesTableViewCell).configure(sale.licenses![indexPath.row - 5 - (products?.count)!])
        }
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if cells[indexPath.row] == CellType.Customer {
            guard let item = customer else {
                return
            }
            let customerObject = Customer.objectForData(AppDelegate.sharedInstance.managedObjectContext, displayName: item["info"]["display_name"].stringValue, email: item["info"]["email"].stringValue, firstName: item["info"]["first_name"].stringValue, lastName: item["info"]["last_name"].stringValue, totalDownloads: item["stats"]["total_downloads"].int64Value, totalPurchases: item["stats"]["total_purchases"].int64Value, totalSpent: item["stats"]["total_spent"].doubleValue, uid: item["info"]["user_id"].int64Value, username: item["username"].stringValue, dateCreated: sharedDateFormatter.dateFromString(item["info"]["date_created"].stringValue)!)
            navigationController?.pushViewController(CustomersDetailViewController(customer: customerObject), animated: true)
        }
        
        if cells[indexPath.row] == CellType.Product {
            let product: JSON = sale.products[indexPath.row - 2]
            let id = product["id"].int64Value
            
            if let product = Product.productForId(id) {
                navigationController?.pushViewController(ProductsDetailViewController(product: product), animated: true)
            } else {
                navigationController?.pushViewController(ProductsOfflineViewController(id: id), animated: true)
            }
        }
        
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}
