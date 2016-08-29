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

class FileDownloadLogsDetailViewController: SiteTableViewController {
    
    private enum CellType {
        case Meta
        case Product
        case Payment
        case Customer
    }
    
    private var cells = [CellType]()

    var site: Site?
    var log: [String: AnyObject]?
    
    init(log: [String: AnyObject]) {
        super.init(style: .Plain)
        
        self.site = Site.activeSite()
        self.log = log
        
        title = log["product_name"] as? String
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
        
        tableView.registerClass(FileDownloadLogsMetaTableViewCell.self, forCellReuseIdentifier: "FileDownloadLogMetaCell")
        tableView.registerClass(FileDownloadLogsCustomerTableViewCell.self, forCellReuseIdentifier: "FileDownloadLogCustomerCell")
        tableView.registerClass(FileDownloadLogsPaymentTableViewCell.self, forCellReuseIdentifier: "FileDownloadLogPaymentCell")
        tableView.registerClass(FileDownloadLogsProductTableViewCell.self, forCellReuseIdentifier: "FileDownloadLogProductCell")
        
        cells = [.Meta, .Product, .Payment, .Customer]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Table View Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        switch cells[indexPath.row] {
//            case .Meta:
//            case .Customer:
//            case .Payment:
//            case .Product:
//        }
    }
    
    // MARK: Table View Delegate
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        switch cells[indexPath.row] {
            case .Meta:
                cell = tableView.dequeueReusableCellWithIdentifier("FileDownloadLogMetaCell", forIndexPath: indexPath) as! FileDownloadLogsMetaTableViewCell
                (cell as! FileDownloadLogsMetaTableViewCell).setTitle(NSLocalizedString("Meta", comment: "Meta title"))
                (cell as! FileDownloadLogsMetaTableViewCell).configure(log!)
                (cell as! FileDownloadLogsMetaTableViewCell).layout()
            case .Customer:
                cell = tableView.dequeueReusableCellWithIdentifier("FileDownloadLogCustomerCell", forIndexPath: indexPath) as! FileDownloadLogsCustomerTableViewCell
                (cell as! FileDownloadLogsCustomerTableViewCell).setTitle(NSLocalizedString("Customer", comment: "Customser title"))
                (cell as! FileDownloadLogsCustomerTableViewCell).layout()
            case .Payment:
                cell = tableView.dequeueReusableCellWithIdentifier("FileDownloadLogPaymentCell", forIndexPath: indexPath) as! FileDownloadLogsPaymentTableViewCell
                (cell as! FileDownloadLogsPaymentTableViewCell).setTitle(NSLocalizedString("Payment", comment: "Payment title"))
                (cell as! FileDownloadLogsPaymentTableViewCell).layout()
            case .Product:
                cell = tableView.dequeueReusableCellWithIdentifier("FileDownloadLogProductCell", forIndexPath: indexPath) as! FileDownloadLogsProductTableViewCell
                (cell as! FileDownloadLogsProductTableViewCell).setTitle(NSLocalizedString("Product", comment: "Product title"))
                (cell as! FileDownloadLogsProductTableViewCell).layout()
            
        }
        
        return cell!
    }
    

}
