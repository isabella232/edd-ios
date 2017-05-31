//
//  SalesDetailViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 06/09/2016.
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

class SalesDetailViewController: SiteTableViewController {

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
    
    init(sale: Sales) {
        super.init(style: .plain)
        
        self.site = Site.activeSite()
        self.sale = sale
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        
        title = NSLocalizedString("Sale", comment: "") + " #" + "\(sale.ID)"
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(NSLocalizedString("Sale", comment: "") + " #" + "\(sale.ID)")
        navigationItem.titleView = titleLabel
        
        tableView.register(SalesDetailMetaTableViewCell.self, forCellReuseIdentifier: "SalesDetailMetaTableViewCell")
        tableView.register(SalesDetailHeadingTableViewCell.self, forCellReuseIdentifier: "SalesDetailHeadingTableViewCell")
        tableView.register(SalesDetailProductTableViewCell.self, forCellReuseIdentifier: "SalesDetailProductTableViewCell")
        tableView.register(SalesDetailCustomerTableViewCell.self, forCellReuseIdentifier: "SalesDetailCustomerTableViewCell")
        tableView.register(SalesDetailLicensesTableViewCell.self, forCellReuseIdentifier: "SalesDetailLicensesTableViewCell")
        
        cells = [.meta, .productsHeading]
        
        EDDAPIWrapper.sharedInstance.requestCustomers(["customer": sale.email as AnyObject], success: { json in
            let items = json["customers"].arrayValue
            self.customer = items[0]
            DispatchQueue.main.async(execute: { 
                self.tableView.reloadData()
            })
            }) { (error) in
                print(error.localizedDescription)
        }
        
        if sale.products!.count == 1 {
            cells.append(.product)
        } else {
            for _ in 1...sale.products!.count {
                cells.append(.product)
            }
        }
        
        if let items = sale.products {
            products = [JSON]()
            for item in items {
                products.append(item)
            }
        }

        cells.append(.customerHeading)
        cells.append(.customer)
        
        if sale.licenses != nil {
            cells.append(.licensesHeading)
            
            if sale.licenses!.count == 1 {
                cells.append(.license)
            } else {
                licenses = [JSON]()
                for _ in 1...sale.licenses!.count {
                    cells.append(.license)
                }
            }
        }
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
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
            let customerObject = Customer.objectForData(AppDelegate.sharedInstance.managedObjectContext, displayName: item["info"]["display_name"].stringValue, email: item["info"]["email"].stringValue, firstName: item["info"]["first_name"].stringValue, lastName: item["info"]["last_name"].stringValue, totalDownloads: item["stats"]["total_downloads"].int64Value, totalPurchases: item["stats"]["total_purchases"].int64Value, totalSpent: item["stats"]["total_spent"].doubleValue, uid: item["info"]["customer_id"].int64Value, username: item["username"].stringValue, dateCreated: sharedDateFormatter.date(from: item["info"]["date_created"].stringValue)!)
//            navigationController?.pushViewController(CustomersDetailViewController(customer: customerObject), animated: true)
            navigationController?.pushViewController(CustomerOfflineViewController(email: item["info"]["email"].stringValue), animated: true)
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
