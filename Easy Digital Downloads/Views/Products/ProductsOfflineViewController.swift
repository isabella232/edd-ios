//
//  ProductsOfflineViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 03/10/2016.
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

class ProductsOfflineViewController: SiteTableViewController {
    
    var managedObjectContext: NSManagedObjectContext!

    private enum CellType {
        case InfoHeading
        case Info
        case StatsHeading
        case Stats
        case PricingHeading
        case Pricing
        case NotesHeading
        case Notes
        case FilesHeading
        case Files
        case LicensingHeading
        case Licensing
    }
    
    private var cells = [CellType]()
    
    var site: Site?
    var product: Product?
    var productId: NSNumber?
    var fetchedProduct: [JSON]?
    var imageView: UIImageView?
    var operation: Bool = false
    
    var loadingView = UIView()
    
    init(id: NSNumber) {
        super.init(style: .Plain)
        
        site = Site.activeSite()
        managedObjectContext = AppDelegate.sharedInstance.managedObjectContext
        productId = id
        
        title = NSLocalizedString("Fetching Product...", comment: "")
        
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
        
        tableView.registerClass(ProductsDetailHeadingTableViewCell.self, forCellReuseIdentifier: "ProductHeadingTableViewCell")
        tableView.registerClass(ProductsDetailInfoTableViewCell.self, forCellReuseIdentifier: "ProductInfoTableViewCell")
        tableView.registerClass(ProductsDetailStatsTableViewCell.self, forCellReuseIdentifier: "ProductStatsTableViewCell")
        tableView.registerClass(ProductsDetailPricingTableViewCell.self, forCellReuseIdentifier: "ProductPricingTableViewCell")
        tableView.registerClass(ProductsDetailLicensingTableViewCell.self, forCellReuseIdentifier: "ProductLicensingTableViewCell")
        tableView.registerClass(ProductsDetailFilesTableViewCell.self, forCellReuseIdentifier: "ProductFilesTableViwCell")
        
        cells = [.InfoHeading, .Info, .StatsHeading, .Stats, .PricingHeading, .Pricing]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Private
    
    private func setupHeaderView() {
        guard product != nil else {
            return
        }
        
        imageView = UIImageView(frame: CGRectMake(0, 0, view.frame.width, 150))
        imageView!.contentMode = .ScaleAspectFill
        
        let url = NSURL(string: product!.thumbnail!)
        imageView!.af_setImageWithURL(url!, placeholderImage: nil, filter: nil, progress: nil, progressQueue: dispatch_get_main_queue(), imageTransition: .CrossDissolve(0.2), runImageTransitionIfCached: true, completion: nil)
        
        tableView.addSubview(imageView!)
        tableView.sendSubviewToBack(imageView!)
        tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, tableView.bounds.width, 150))
    }
    
    private func networkOperations() {
        self.operation = true
        view.addSubview(loadingView)

        EDDAPIWrapper.sharedInstance.requestProducts(["product": "\(productId)"], success: { (json) in
            if let items = json["products"].array {
                self.fetchedProduct = items
                
                self.loadingView.removeFromSuperview()
                
                let item = items[0]
                
                if let _ = item["files"].array {
                    self.cells.append(.FilesHeading)
                    self.cells.append(.Files)
                }
                
                if let notes = item["notes"].string {
                    if notes.characters.count > 0 {
                        self.cells.append(.NotesHeading)
                        self.cells.append(.Notes)
                    }
                }
                
                if let _ = item["licensing"].array {
                    self.cells.append(.LicensingHeading)
                    self.cells.append(.Licensing)
                }
                
                if let thumbnail = item["info"]["thumbnail"].string {
                    if thumbnail.characters.count > 0 {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.setupHeaderView()
                        })
                    }
                }
                
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
                
                self.operation = true
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.title = self.product?.title
                    self.operation = false
                    self.loadingView.removeFromSuperview()
                    self.tableView.reloadData()
                })
            }
        }) { (error) in
            fatalError()
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        switch(cells[indexPath.row]) {
        case .InfoHeading:
            cell = tableView.dequeueReusableCellWithIdentifier("ProductHeadingTableViewCell", forIndexPath: indexPath) as! ProductsDetailHeadingTableViewCell
            (cell as! ProductsDetailHeadingTableViewCell).configure("Info")
        case .Info:
            cell = tableView.dequeueReusableCellWithIdentifier("ProductInfoTableViewCell", forIndexPath: indexPath) as! ProductsDetailInfoTableViewCell
            (cell as! ProductsDetailInfoTableViewCell).configure(product!)
        case .StatsHeading:
            cell = tableView.dequeueReusableCellWithIdentifier("ProductHeadingTableViewCell", forIndexPath: indexPath) as! ProductsDetailHeadingTableViewCell
            (cell as! ProductsDetailHeadingTableViewCell).configure("Stats")
        case .Stats:
            cell = tableView.dequeueReusableCellWithIdentifier("ProductStatsTableViewCell", forIndexPath: indexPath) as! ProductsDetailStatsTableViewCell
            (cell as! ProductsDetailStatsTableViewCell).configure(product?.stats)
        case .PricingHeading:
            cell = tableView.dequeueReusableCellWithIdentifier("ProductHeadingTableViewCell", forIndexPath: indexPath) as! ProductsDetailHeadingTableViewCell
            (cell as! ProductsDetailHeadingTableViewCell).configure("Pricing")
        case .Pricing:
            cell = tableView.dequeueReusableCellWithIdentifier("ProductPricingTableViewCell", forIndexPath: indexPath) as! ProductsDetailPricingTableViewCell
            (cell as! ProductsDetailPricingTableViewCell).configure((product?.hasVariablePricing.boolValue)!, pricing: product!.pricing)
        case .LicensingHeading:
            cell = tableView.dequeueReusableCellWithIdentifier("ProductHeadingTableViewCell", forIndexPath: indexPath) as! ProductsDetailHeadingTableViewCell
            (cell as! ProductsDetailHeadingTableViewCell).configure("Licensing")
        case .Licensing:
            cell = tableView.dequeueReusableCellWithIdentifier("ProductLicensingTableViewCell", forIndexPath: indexPath) as! ProductsDetailLicensingTableViewCell
            (cell as! ProductsDetailLicensingTableViewCell).configure(product!.licensing!)
        case .FilesHeading:
            cell = tableView.dequeueReusableCellWithIdentifier("ProductHeadingTableViewCell", forIndexPath: indexPath) as! ProductsDetailHeadingTableViewCell
            (cell as! ProductsDetailHeadingTableViewCell).configure("Files")
        case .Files:
            cell = tableView.dequeueReusableCellWithIdentifier("ProductFilesTableViwCell", forIndexPath: indexPath) as! ProductsDetailFilesTableViewCell
            (cell as! ProductsDetailFilesTableViewCell).configure(product!.files!)
        case .NotesHeading:
            cell = tableView.dequeueReusableCellWithIdentifier("ProductHeadingTableViewCell", forIndexPath: indexPath) as! ProductsDetailHeadingTableViewCell
            (cell as! ProductsDetailHeadingTableViewCell).configure("Notes")
        case .Notes:
            cell = tableView.dequeueReusableCellWithIdentifier("ProductLicensingTableViewCell", forIndexPath: indexPath) as! ProductsDetailLicensingTableViewCell
            (cell as! ProductsDetailLicensingTableViewCell).configure(product!.licensing!)
        }
        
        return cell!
    }
    
    // MARK: Scroll View Delegate
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let y: CGFloat = -tableView.contentOffset.y
        if y > 0 {
            imageView!.frame = CGRectMake(0, tableView.contentOffset.y, tableView.bounds.width + y, 150 + y)
            imageView!.center = CGPointMake(view.center.x, imageView!.center.y)
        }
    }


}
