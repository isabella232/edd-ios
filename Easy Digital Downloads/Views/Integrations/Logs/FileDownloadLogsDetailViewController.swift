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

private let sharedDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}()

class FileDownloadLogsDetailViewController: SiteTableViewController {
    
    private enum CellType {
        case Title
        case MetaHeading
        case Meta
        case ProductHeading
        case Product
        case PaymentHeading
        case Payment
        case CustomerHeading
        case Customer
    }
    
    private var cells = [CellType]()

    var site: Site?
    var log: Log!
    var product: Product?
    var payment: Sales?
    var customer: Customer?
    
    var paymentId: Int64 = 0
    var customerId: Int64 = 0
    var productId: Int64 = 0
    
    init(log: Log) {
        super.init(style: .Plain)
        
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
        tableView.separatorStyle = .None
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(log.productName)
        navigationItem.titleView = titleLabel
        
        setupDataSource()
        networkOperations()
        
        tableView.registerClass(FileDownloadLogsMetaTableViewCell.self, forCellReuseIdentifier: "FileDownloadLogMetaCell")
        tableView.registerClass(FileDownloadLogsCustomerTableViewCell.self, forCellReuseIdentifier: "FileDownloadLogCustomerCell")
        tableView.registerClass(FileDownloadLogsPaymentTableViewCell.self, forCellReuseIdentifier: "FileDownloadLogPaymentCell")
        tableView.registerClass(FileDownloadLogsProductTableViewCell.self, forCellReuseIdentifier: "FileDownloadLogProductCell")
        tableView.registerClass(FileDownloadLogsHeadingTableViewCell.self, forCellReuseIdentifier: "FileDownloadLogsHeadingCell")
        tableView.registerClass(FileDownloadLogsTitleTableViewCell.self, forCellReuseIdentifier: "FileDownloadLogsTitleCell")
        
        cells = [.Title, .MetaHeading, .Meta, .ProductHeading, .Product, .PaymentHeading, .Payment, .CustomerHeading, .Customer]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupDataSource() {
        if let product = Product.productForId(log.productId) {
            self.product = product
            dispatch_async(dispatch_get_main_queue(), { 
                self.tableView.reloadData()
            })
        }
        
        if let customer = Customer.customerForId(log.customerId) {
            self.customer = customer
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
    }
    
    func networkOperations() {
        EDDAPIWrapper.sharedInstance.requestCustomers(["customer" : "\(log.customerId)"], success: { (json) in
            if let items = json["customers"].array {
                let item = items[0]
                
                self.customer = Customer.objectForData(AppDelegate.sharedInstance.managedObjectContext, displayName: item["info"]["display_name"].stringValue, email: item["info"]["email"].stringValue, firstName: item["info"]["first_name"].stringValue, lastName: item["info"]["last_name"].stringValue, totalDownloads: item["stats"]["total_downloads"].int64Value, totalPurchases: item["stats"]["total_purchases"].int64Value, totalSpent: item["stats"]["total_spent"].doubleValue, uid: item["info"]["user_id"].int64Value, username: item["username"].stringValue, dateCreated: sharedDateFormatter.dateFromString(item["info"]["date_created"].stringValue)!)
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
        }) { (error) in
            NSLog(error.localizedDescription)
        }
        
        EDDAPIWrapper.sharedInstance.requestSales(["id" : "\(log.paymentId)"], success: { (json) in
            if let items = json["sales"].array {
                let item = items[0]
                
                self.payment = Sales(ID: item["ID"].int64Value, transactionId: item["transaction_id"].string, key: item["key"].string, subtotal: item["subtotal"].doubleValue, tax: item["tax"].double, fees: item["fees"].array, total: item["total"].doubleValue, gateway: item["gateway"].stringValue, email: item["email"].stringValue, date: sharedDateFormatter.dateFromString(item["date"].stringValue), discounts: item["discounts"].dictionary, products: item["products"].arrayValue, licenses: item["licenses"].array)
                
                dispatch_async(dispatch_get_main_queue(), {
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
        return cells.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if cells[indexPath.row] == .Customer {
            guard customer != nil else {
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                return
            }
            navigationController?.pushViewController(CustomersDetailViewController(customer: customer!), animated: true)
        }
        
        if cells[indexPath.row] == .Product {
            guard product != nil else {
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                return
            }
            navigationController?.pushViewController(ProductsDetailViewController(product: product!), animated: true)
        }
        
        if cells[indexPath.row] == .Payment {
            guard payment != nil else {
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                return
            }
            navigationController?.pushViewController(SalesDetailViewController(sale: payment!), animated: true)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: Table View Delegate
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        switch cells[indexPath.row] {
            case .Title:
                cell = tableView.dequeueReusableCellWithIdentifier("FileDownloadLogsTitleCell", forIndexPath: indexPath) as! FileDownloadLogsTitleTableViewCell
                (cell as! FileDownloadLogsTitleTableViewCell).configure("Log #\(log.ID)")
            case .MetaHeading:
                cell = tableView.dequeueReusableCellWithIdentifier("FileDownloadLogsHeadingCell", forIndexPath: indexPath) as! FileDownloadLogsHeadingTableViewCell
                (cell as! FileDownloadLogsHeadingTableViewCell).configure("Meta")
            case .Meta:
                cell = tableView.dequeueReusableCellWithIdentifier("FileDownloadLogMetaCell", forIndexPath: indexPath) as! FileDownloadLogsMetaTableViewCell
                (cell as! FileDownloadLogsMetaTableViewCell).configure(log)
                (cell as! FileDownloadLogsMetaTableViewCell).layout()
            case .CustomerHeading:
                cell = tableView.dequeueReusableCellWithIdentifier("FileDownloadLogsHeadingCell", forIndexPath: indexPath) as! FileDownloadLogsHeadingTableViewCell
                (cell as! FileDownloadLogsHeadingTableViewCell).configure("Customer")
            case .Customer:
                cell = tableView.dequeueReusableCellWithIdentifier("FileDownloadLogCustomerCell", forIndexPath: indexPath) as! FileDownloadLogsCustomerTableViewCell
                (cell as! FileDownloadLogsCustomerTableViewCell).configureForObject(customer)
            case .PaymentHeading:
                cell = tableView.dequeueReusableCellWithIdentifier("FileDownloadLogsHeadingCell", forIndexPath: indexPath) as! FileDownloadLogsHeadingTableViewCell
                (cell as! FileDownloadLogsHeadingTableViewCell).configure("Payment")
            case .Payment:
                cell = tableView.dequeueReusableCellWithIdentifier("FileDownloadLogPaymentCell", forIndexPath: indexPath) as! FileDownloadLogsPaymentTableViewCell
                (cell as! FileDownloadLogsPaymentTableViewCell).configure(payment)
            case .ProductHeading:
                cell = tableView.dequeueReusableCellWithIdentifier("FileDownloadLogsHeadingCell", forIndexPath: indexPath) as! FileDownloadLogsHeadingTableViewCell
                (cell as! FileDownloadLogsHeadingTableViewCell).configure("Product")
            case .Product:
                cell = tableView.dequeueReusableCellWithIdentifier("FileDownloadLogProductCell", forIndexPath: indexPath) as! FileDownloadLogsProductTableViewCell
                (cell as! FileDownloadLogsProductTableViewCell).configureForObject(product)
            
        }
        
        return cell!
    }

}
