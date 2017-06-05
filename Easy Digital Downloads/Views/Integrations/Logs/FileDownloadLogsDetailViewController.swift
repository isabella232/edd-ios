//
//  FileDownloadLogsDetailViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 22/08/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON

private let sharedDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}()

class FileDownloadLogsDetailViewController: SiteTableViewController {
    
    fileprivate enum CellType {
        case title
        case metaHeading
        case meta
        case productHeading
        case product
        case paymentHeading
        case payment
        case customerHeading
        case customer
    }
    
    fileprivate var cells = [CellType]()

    var site: Site?
    var log: Log!
    var product: Product?
    var payment: Sales?
    var customer: Customer?
    
    var paymentId: Int64 = 0
    var customerId: Int64 = 0
    var productId: Int64 = 0
    
    init(log: Log) {
        super.init(style: .plain)
        
        self.site = Site.activeSite()
        self.log = log
        
        self.paymentId = log.paymentId
        self.customerId = log.customerId
        self.productId = log.productId
        
        title = log.productName
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(log.productName)
        navigationItem.titleView = titleLabel
        
        setupDataSource()
        networkOperations()
        
        tableView.register(FileDownloadLogsMetaTableViewCell.self, forCellReuseIdentifier: "FileDownloadLogMetaCell")
        tableView.register(FileDownloadLogsCustomerTableViewCell.self, forCellReuseIdentifier: "FileDownloadLogCustomerCell")
        tableView.register(FileDownloadLogsPaymentTableViewCell.self, forCellReuseIdentifier: "FileDownloadLogPaymentCell")
        tableView.register(FileDownloadLogsProductTableViewCell.self, forCellReuseIdentifier: "FileDownloadLogProductCell")
        tableView.register(FileDownloadLogsHeadingTableViewCell.self, forCellReuseIdentifier: "FileDownloadLogsHeadingCell")
        tableView.register(FileDownloadLogsTitleTableViewCell.self, forCellReuseIdentifier: "FileDownloadLogsTitleCell")
        
        cells = [.title, .metaHeading, .meta, .productHeading, .product]
        
        if log.paymentId > 0 {
            cells.append(.paymentHeading)
            cells.append(.payment)
        }
        
        if log.customerId > 0 {
            cells.append(.customerHeading)
            cells.append(.customer)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupDataSource() {
        if let product = Product.productForId(log.productId) {
            self.product = product
            DispatchQueue.main.async(execute: { 
                self.tableView.reloadData()
            })
        }
        
        if let customer = Customer.customerForId(log.customerId) {
            self.customer = customer
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        }
    }
    
    func networkOperations() {
        if log.customerId > 0 {
            EDDAPIWrapper.sharedInstance.requestCustomers(["customer" : "\(log.customerId)" as AnyObject], success: { (json) in
                if let items = json["customers"].array {
                    let item = items[0]
                    
                    self.customer = Customer.objectForData(AppDelegate.sharedInstance.managedObjectContext, displayName: item["info"]["display_name"].stringValue, email: item["info"]["email"].stringValue, firstName: item["info"]["first_name"].stringValue, lastName: item["info"]["last_name"].stringValue, totalDownloads: item["stats"]["total_downloads"].int64Value, totalPurchases: item["stats"]["total_purchases"].int64Value, totalSpent: item["stats"]["total_spent"].doubleValue, uid: item["info"]["customer_id"].int64Value, username: item["username"].stringValue, dateCreated: sharedDateFormatter.date(from: item["info"]["date_created"].stringValue)!)
                    
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                }
            }) { (error) in
                NSLog(error.localizedDescription)
            }
        }
        
        if log.paymentId > 0 {
            EDDAPIWrapper.sharedInstance.requestSales(["id" : "\(log.paymentId)" as AnyObject], success: { (json) in
                if let items = json["sales"].array {
                    let item = items[0]
                    
                    self.payment = Sales(ID: item["ID"].int64Value, transactionId: item["transaction_id"].string, key: item["key"].string, subtotal: item["subtotal"].doubleValue, tax: item["tax"].double, fees: item["fees"].array, total: item["total"].doubleValue, gateway: item["gateway"].stringValue, email: item["email"].stringValue, date: sharedDateFormatter.date(from: item["date"].stringValue), discounts: item["discounts"].dictionary, products: item["products"].arrayValue, licenses: item["licenses"].array)
                    
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                }
            }) { (error) in
                NSLog(error.localizedDescription)
            }
        }
    }
    
    // MARK: Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if cells[indexPath.row] == .customer {
            guard customer != nil else {
                tableView.deselectRow(at: indexPath, animated: true)
                return
            }
            navigationController?.pushViewController(CustomersDetailViewController(customer: customer!), animated: true)
        }
        
        if cells[indexPath.row] == .product {
            guard product != nil else {
                tableView.deselectRow(at: indexPath, animated: true)
                return
            }
            navigationController?.pushViewController(ProductsDetailViewController(product: product!), animated: true)
        }
        
        if cells[indexPath.row] == .payment {
            guard payment != nil else {
                tableView.deselectRow(at: indexPath, animated: true)
                return
            }
            navigationController?.pushViewController(SalesDetailViewController(sale: payment!), animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        switch cells[indexPath.row] {
            case .title:
                cell = tableView.dequeueReusableCell(withIdentifier: "FileDownloadLogsTitleCell", for: indexPath) as! FileDownloadLogsTitleTableViewCell
                if let id = log.ID {
                    (cell as! FileDownloadLogsTitleTableViewCell).configure("Log #\(id)")
                }
            case .metaHeading:
                cell = tableView.dequeueReusableCell(withIdentifier: "FileDownloadLogsHeadingCell", for: indexPath) as! FileDownloadLogsHeadingTableViewCell
                (cell as! FileDownloadLogsHeadingTableViewCell).configure("Meta")
            case .meta:
                cell = tableView.dequeueReusableCell(withIdentifier: "FileDownloadLogMetaCell", for: indexPath) as! FileDownloadLogsMetaTableViewCell
                (cell as! FileDownloadLogsMetaTableViewCell).configure(log)
                (cell as! FileDownloadLogsMetaTableViewCell).layout()
            case .customerHeading:
                cell = tableView.dequeueReusableCell(withIdentifier: "FileDownloadLogsHeadingCell", for: indexPath) as! FileDownloadLogsHeadingTableViewCell
                (cell as! FileDownloadLogsHeadingTableViewCell).configure("Customer")
            case .customer:
                cell = tableView.dequeueReusableCell(withIdentifier: "FileDownloadLogCustomerCell", for: indexPath) as! FileDownloadLogsCustomerTableViewCell
                (cell as! FileDownloadLogsCustomerTableViewCell).configureForObject(customer)
            case .paymentHeading:
                cell = tableView.dequeueReusableCell(withIdentifier: "FileDownloadLogsHeadingCell", for: indexPath) as! FileDownloadLogsHeadingTableViewCell
                (cell as! FileDownloadLogsHeadingTableViewCell).configure("Payment")
            case .payment:
                cell = tableView.dequeueReusableCell(withIdentifier: "FileDownloadLogPaymentCell", for: indexPath) as! FileDownloadLogsPaymentTableViewCell
                (cell as! FileDownloadLogsPaymentTableViewCell).configure(payment)
            case .productHeading:
                cell = tableView.dequeueReusableCell(withIdentifier: "FileDownloadLogsHeadingCell", for: indexPath) as! FileDownloadLogsHeadingTableViewCell
                (cell as! FileDownloadLogsHeadingTableViewCell).configure("Product")
            case .product:
                cell = tableView.dequeueReusableCell(withIdentifier: "FileDownloadLogProductCell", for: indexPath) as! FileDownloadLogsProductTableViewCell
                (cell as! FileDownloadLogsProductTableViewCell).configureForObject(product)
            
        }
        
        return cell!
    }

}
