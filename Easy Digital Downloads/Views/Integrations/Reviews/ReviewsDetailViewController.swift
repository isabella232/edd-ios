//
//  ReviewsDetailViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 22/08/2016.
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

class ReviewsDetailViewController: SiteTableViewController {

    fileprivate enum CellType {
        case metaHeading
        case meta
        case productHeading
        case product
    }
    
    fileprivate var cells = [CellType]()
    
    var site: Site?
    var review: Review?
    var product: Product?
    
    init(review: Review) {
        super.init(style: .plain)
        
        self.site = Site.activeSite()
        self.review = review
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        
        title = review.title
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(review.title)
        navigationItem.titleView = titleLabel
        
        networkOperations()
        
        tableView.register(ReviewsDetailMetaTableViewCell.self, forCellReuseIdentifier: "ReviewsDetailMetaTableViewCell")
        tableView.register(ReviewsDetailHeadingTableViewCell.self, forCellReuseIdentifier: "ReviewsDetailHeadingTableViewCell")
        tableView.register(ReviewsDetailProductTableViewCell.self, forCellReuseIdentifier: "ReviewsDetailProductTableViewCell")
        
        cells = [.metaHeading, .meta, .productHeading, .product]
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func networkOperations() {
        if let product = Product.productForId(review!.downloadId) {
            self.product = product
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        } else {
            EDDAPIWrapper.sharedInstance.requestProducts(["id" : "\(review!.downloadId)" as AnyObject], success: { (json) in
                if let items = json["products"].array {
                    let item = items[0]
                    
                    var stats: NSData?
                    if Site.hasPermissionToViewReports() {
                        stats = NSKeyedArchiver.archivedData(withRootObject: item["stats"].dictionaryObject!) as NSData
                    } else {
                        stats = nil
                    }
                    
                    var files: NSData?
                    var notes: String?
                    if Site.hasPermissionToViewSensitiveData() {
                        if item["files"].arrayObject != nil {
                            files = NSKeyedArchiver.archivedData(withRootObject: item["files"].arrayObject!) as NSData
                        } else {
                            files = nil
                        }
                        
                        notes = item["notes"].stringValue
                    } else {
                        files = nil
                        notes = nil
                    }
                    
                    var hasVariablePricing = false
                    if (item["pricing"].dictionary?.count)! > 1 {
                        hasVariablePricing = true
                    }
                    
                    let pricing = NSKeyedArchiver.archivedData(withRootObject: item["pricing"].dictionaryObject!)
                    
                    self.product = Product.objectForData(AppDelegate.sharedInstance.managedObjectContext, content: item["info"]["content"].stringValue, createdDate: sharedDateFormatter.date(from: item["info"]["create_date"].stringValue)!, files: files! as Data, hasVariablePricing: hasVariablePricing as NSNumber, link: item["info"]["link"].stringValue, modifiedDate: sharedDateFormatter.date(from: item["info"]["modified_date"].stringValue)!, notes: notes, pid: item["info"]["id"].int64Value, pricing: pricing, stats: stats as Data?, status: item["info"]["status"].stringValue, thumbnail: item["info"]["thumbnail"].stringValue, title: item["info"]["title"].stringValue, licensing: item["licensing"].dictionaryObject as [String : AnyObject]?)
                    
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                }
                }, failure: { (error) in
                    print(error)
            })
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
        guard let product_ = product else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        if cells[indexPath.row] == .product {
            navigationController?.pushViewController(ProductsDetailViewController(product: product_), animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        switch cells[indexPath.row] {
            case .metaHeading:
                cell = tableView.dequeueReusableCell(withIdentifier: "ReviewsDetailHeadingTableViewCell", for: indexPath) as! ReviewsDetailHeadingTableViewCell
                (cell as! ReviewsDetailHeadingTableViewCell).configure("Meta")
            case .meta:
                cell = tableView.dequeueReusableCell(withIdentifier: "ReviewsDetailMetaTableViewCell", for: indexPath) as! ReviewsDetailMetaTableViewCell
                (cell as! ReviewsDetailMetaTableViewCell).configure(review!)
            case .productHeading:
                cell = tableView.dequeueReusableCell(withIdentifier: "ReviewsDetailHeadingTableViewCell", for: indexPath) as! ReviewsDetailHeadingTableViewCell
                (cell as! ReviewsDetailHeadingTableViewCell).configure("Product")
            case .product:
                cell = tableView.dequeueReusableCell(withIdentifier: "ReviewsDetailProductTableViewCell", for: indexPath) as! ReviewsDetailProductTableViewCell
                (cell as! ReviewsDetailProductTableViewCell).configureForObject(product)
        }
     
        return cell!
    }
    
}
