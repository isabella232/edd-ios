//
//  DiscountsDetailViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 18/10/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON

private let sharedDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}()

class DiscountsDetailViewController: SiteTableViewController {

    fileprivate enum CellType {
        case metaHeading
        case meta
        case productRequirementsHeading
        case productRequirements
    }
    
    fileprivate var cells = [CellType]()
    
    var site: Site?
    var discount: Discounts?
    
    var fetchedProducts: [Product] = [Product]()
    
    init(discount: Discounts) {
        super.init(style: .plain)
        
        self.site = Site.activeSite()
        self.discount = discount
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        
        title = NSLocalizedString("Discount", comment: "") + " #" + "\(discount.ID)"
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(NSLocalizedString("Discount", comment: "") + " #" + "\(discount.ID)")
        navigationItem.titleView = titleLabel
        
        setupDataSource()
        networkOperations()
        
        tableView.register(DiscountsDetailMetaTableViewCell.self, forCellReuseIdentifier: "DiscountsDetailMetaTableViewCell")
        tableView.register(DiscountsDetailProductRequirementTableViewCell.self, forCellReuseIdentifier: "DiscountsDetailProductRequirementTableViewCell")
        tableView.register(DiscountsDetailHeadingTableViewCell.self, forCellReuseIdentifier: "DiscountsDetailHeadingTableViewCell")
        
        cells = [.metaHeading, .meta]
        
        if let requirements = discount.productRequirements {
            cells.append(.productRequirementsHeading)
            
            if requirements.count == 1 {
                self.cells.append(.productRequirements)
            } else {
                for _ in 1...requirements.count {
                    self.cells.append(.ProductRequirements)
                }
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Private
    
    fileprivate func setupDataSource() {
        if let requirements = discount?.productRequirements {
            for item in requirements {
                if let product = Product.productForId(item.1.int64Value) {
                    self.fetchedProducts.append(product)
                } else {
                    EDDAPIWrapper.sharedInstance.requestProducts(["product" : item.1.stringValue], success: { (json) in
                        
                        }, failure: { (error) in
                            print(error)
                    })
                }
            }
            
            DispatchQueue.main.async(execute: { 
                self.tableView.reloadData()
            })
            
        }
    }
    
    fileprivate func networkOperations() {
        if let requirements = discount?.productRequirements {
            for item in requirements {
                EDDAPIWrapper.sharedInstance.requestProducts(["product" : item.1.stringValue], success: { (json) in
                    
                }, failure: { (error) in
                    print(error)
                })
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
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        switch cells[indexPath.row] {
            case .metaHeading:
                cell = tableView.dequeueReusableCell(withIdentifier: "DiscountsDetailHeadingTableViewCell", for: indexPath) as! DiscountsDetailHeadingTableViewCell
                (cell as! DiscountsDetailHeadingTableViewCell).configure("Meta")
            case .meta:
                cell = tableView.dequeueReusableCell(withIdentifier: "DiscountsDetailMetaTableViewCell", for: indexPath) as! DiscountsDetailMetaTableViewCell
                (cell as! DiscountsDetailMetaTableViewCell).configure(discount!)
            case .productRequirementsHeading:
                cell = tableView.dequeueReusableCell(withIdentifier: "DiscountsDetailHeadingTableViewCell", for: indexPath) as! DiscountsDetailHeadingTableViewCell
                (cell as! DiscountsDetailHeadingTableViewCell).configure("Product Requirements")
            case .productRequirements:
                cell = tableView.dequeueReusableCell(withIdentifier: "DiscountsDetailProductRequirementTableViewCell", for: indexPath) as! DiscountsDetailProductRequirementTableViewCell
                if self.fetchedProducts.indices.contains(indexPath.row - 3) {
                    (cell as! DiscountsDetailProductRequirementTableViewCell).configure(self.fetchedProducts[indexPath.row - 3])
                } else {
                    (cell as! DiscountsDetailProductRequirementTableViewCell).configure(nil)
            }
                
        }
        
        return cell!
    }

}
