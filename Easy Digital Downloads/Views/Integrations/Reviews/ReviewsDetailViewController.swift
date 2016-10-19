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

private let sharedDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}()

class ReviewsDetailViewController: SiteTableViewController {

    private enum CellType {
        case MetaHeading
        case Meta
        case ProductHeading
        case Product
    }
    
    private var cells = [CellType]()
    
    var site: Site?
    var review: Review?
    var product: Product?
    
    init(review: Review) {
        super.init(style: .Plain)
        
        self.site = Site.activeSite()
        self.review = review
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
        
        title = review.title
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(review.title)
        navigationItem.titleView = titleLabel
        
        networkOperations()
        
        tableView.registerClass(ReviewsDetailMetaTableViewCell.self, forCellReuseIdentifier: "ReviewsDetailMetaTableViewCell")
        tableView.registerClass(ReviewsDetailHeadingTableViewCell.self, forCellReuseIdentifier: "ReviewsDetailHeadingTableViewCell")
        tableView.registerClass(ReviewsDetailProductTableViewCell.self, forCellReuseIdentifier: "ReviewsDetailProductTableViewCell")
        
        cells = [.MetaHeading, .Meta, .ProductHeading, .Product]
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func networkOperations() {
        if let product = Product.productForId(review!.downloadId) {
            self.product = product
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        } else {
            EDDAPIWrapper.sharedInstance.requestProducts(["id" : "\(review!.downloadId)"], success: { (json) in
                if let items = json["products"].array {
                    let item = items[0]
                    
                    var stats: NSData?
                    if Site.hasPermissionToViewReports() {
                        stats = NSKeyedArchiver.archivedDataWithRootObject(item["stats"].dictionaryObject!)
                    } else {
                        stats = nil
                    }
                    
                    var files: NSData?
                    var notes: String?
                    if Site.hasPermissionToViewSensitiveData() {
                        if item["files"].arrayObject != nil {
                            files = NSKeyedArchiver.archivedDataWithRootObject(item["files"].arrayObject!)
                        } else {
                            files = nil
                        }
                        
                        notes = item["notes"].stringValue
                    } else {
                        files = nil
                        notes = nil
                    }
                    
                    var hasVariablePricing = false
                    if item["pricing"].dictionary?.count > 1 {
                        hasVariablePricing = true
                    }
                    
                    let pricing = NSKeyedArchiver.archivedDataWithRootObject(item["pricing"].dictionaryObject!)
                    
                    self.product = Product.objectForData(AppDelegate.sharedInstance.managedObjectContext, content: item["info"]["content"].stringValue, createdDate: sharedDateFormatter.dateFromString(item["info"]["create_date"].stringValue)!, files: files, hasVariablePricing: hasVariablePricing, link: item["info"]["link"].stringValue, modifiedDate: sharedDateFormatter.dateFromString(item["info"]["modified_date"].stringValue)!, notes: notes, pid: item["info"]["id"].int64Value, pricing: pricing, stats: stats, status: item["info"]["status"].stringValue, thumbnail: item["info"]["thumbnail"].stringValue, title: item["info"]["title"].stringValue, licensing: item["licensing"].dictionaryObject)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                }
                }, failure: { (error) in
                    print(error)
            })
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
        guard let product_ = product else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            return
        }
        
        if cells[indexPath.row] == .Product {
            navigationController?.pushViewController(ProductsDetailViewController(product: product_), animated: true)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: Table View Delegate
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        switch cells[indexPath.row] {
            case .MetaHeading:
                cell = tableView.dequeueReusableCellWithIdentifier("ReviewsDetailHeadingTableViewCell", forIndexPath: indexPath) as! ReviewsDetailHeadingTableViewCell
                (cell as! ReviewsDetailHeadingTableViewCell).configure("Meta")
            case .Meta:
                cell = tableView.dequeueReusableCellWithIdentifier("ReviewsDetailMetaTableViewCell", forIndexPath: indexPath) as! ReviewsDetailMetaTableViewCell
                (cell as! ReviewsDetailMetaTableViewCell).configure(review!)
            case .ProductHeading:
                cell = tableView.dequeueReusableCellWithIdentifier("ReviewsDetailHeadingTableViewCell", forIndexPath: indexPath) as! ReviewsDetailHeadingTableViewCell
                (cell as! ReviewsDetailHeadingTableViewCell).configure("Product")
            case .Product:
                cell = tableView.dequeueReusableCellWithIdentifier("ReviewsDetailProductTableViewCell", forIndexPath: indexPath) as! ReviewsDetailProductTableViewCell
                (cell as! ReviewsDetailProductTableViewCell).configureForObject(product)
        }
     
        return cell!
    }
    
}
