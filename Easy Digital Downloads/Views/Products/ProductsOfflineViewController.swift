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

private let sharedDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}()

class ProductsOfflineViewController: SiteTableViewController {
    
    var managedObjectContext: NSManagedObjectContext!

    fileprivate enum CellType {
        case infoHeading
        case info
        case statsHeading
        case stats
        case pricingHeading
        case pricing
        case notesHeading
        case notes
        case filesHeading
        case files
        case licensingHeading
        case licensing
    }
    
    fileprivate var cells = [CellType]()
    
    var site: Site?
    var product: Product?
    var productId: Int64?
    var fetchedProduct: [JSON]?
    var imageView: UIImageView?
    var operation: Bool = false
    
    var loadingView = UIView()
    
    init(id: Int64) {
        super.init(style: .plain)
        
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
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(NSLocalizedString("Fetching Product...", comment: ""))
        navigationItem.titleView = titleLabel
        
        tableView.register(ProductsDetailHeadingTableViewCell.self, forCellReuseIdentifier: "ProductHeadingTableViewCell")
        tableView.register(ProductsDetailInfoTableViewCell.self, forCellReuseIdentifier: "ProductInfoTableViewCell")
        tableView.register(ProductsDetailStatsTableViewCell.self, forCellReuseIdentifier: "ProductStatsTableViewCell")
        tableView.register(ProductsDetailPricingTableViewCell.self, forCellReuseIdentifier: "ProductPricingTableViewCell")
        tableView.register(ProductsDetailLicensingTableViewCell.self, forCellReuseIdentifier: "ProductLicensingTableViewCell")
        tableView.register(ProductsDetailFilesTableViewCell.self, forCellReuseIdentifier: "ProductFilesTableViwCell")
        
        cells = [.infoHeading, .info, .statsHeading, .stats, .pricingHeading, .pricing]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Private
    
    fileprivate func setupHeaderView() {
        guard product != nil else {
            return
        }
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 150))
        imageView!.contentMode = .scaleAspectFill
        
        let url = URL(string: product!.thumbnail!)
        imageView!.af_setImageWithURL(url!, placeholderImage: nil, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .CrossDissolve(0.2), runImageTransitionIfCached: true, completion: nil)
        
        tableView.addSubview(imageView!)
        tableView.sendSubview(toBack: imageView!)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 150))
    }
    
    fileprivate func networkOperations() {
        self.operation = true
        view.addSubview(loadingView)

        EDDAPIWrapper.sharedInstance.requestProducts(["product": "\(productId!)"], success: { (json) in
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
                    let titleLabel = ViewControllerTitleLabel()
                    titleLabel.setTitle((self.product?.title)!)
                    self.navigationItem.titleView = titleLabel
                    
                    self.operation = false
                    self.loadingView.removeFromSuperview()
                    self.tableView.reloadData()
                })
            }
        }) { (error) in
            print(error)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        switch(cells[indexPath.row]) {
        case .infoHeading:
            cell = tableView.dequeueReusableCell(withIdentifier: "ProductHeadingTableViewCell", for: indexPath) as! ProductsDetailHeadingTableViewCell
            (cell as! ProductsDetailHeadingTableViewCell).configure("Info")
        case .info:
            cell = tableView.dequeueReusableCell(withIdentifier: "ProductInfoTableViewCell", for: indexPath) as! ProductsDetailInfoTableViewCell
            (cell as! ProductsDetailInfoTableViewCell).configure(product!)
        case .statsHeading:
            cell = tableView.dequeueReusableCell(withIdentifier: "ProductHeadingTableViewCell", for: indexPath) as! ProductsDetailHeadingTableViewCell
            (cell as! ProductsDetailHeadingTableViewCell).configure("Stats")
        case .stats:
            cell = tableView.dequeueReusableCell(withIdentifier: "ProductStatsTableViewCell", for: indexPath) as! ProductsDetailStatsTableViewCell
            (cell as! ProductsDetailStatsTableViewCell).configure(product?.stats)
        case .pricingHeading:
            cell = tableView.dequeueReusableCell(withIdentifier: "ProductHeadingTableViewCell", for: indexPath) as! ProductsDetailHeadingTableViewCell
            (cell as! ProductsDetailHeadingTableViewCell).configure("Pricing")
        case .pricing:
            cell = tableView.dequeueReusableCell(withIdentifier: "ProductPricingTableViewCell", for: indexPath) as! ProductsDetailPricingTableViewCell
            (cell as! ProductsDetailPricingTableViewCell).configure((product?.hasVariablePricing.boolValue)!, pricing: product!.pricing)
        case .licensingHeading:
            cell = tableView.dequeueReusableCell(withIdentifier: "ProductHeadingTableViewCell", for: indexPath) as! ProductsDetailHeadingTableViewCell
            (cell as! ProductsDetailHeadingTableViewCell).configure("Licensing")
        case .licensing:
            cell = tableView.dequeueReusableCell(withIdentifier: "ProductLicensingTableViewCell", for: indexPath) as! ProductsDetailLicensingTableViewCell
            (cell as! ProductsDetailLicensingTableViewCell).configure(product!.licensing!)
        case .filesHeading:
            cell = tableView.dequeueReusableCell(withIdentifier: "ProductHeadingTableViewCell", for: indexPath) as! ProductsDetailHeadingTableViewCell
            (cell as! ProductsDetailHeadingTableViewCell).configure("Files")
        case .files:
            cell = tableView.dequeueReusableCell(withIdentifier: "ProductFilesTableViwCell", for: indexPath) as! ProductsDetailFilesTableViewCell
            (cell as! ProductsDetailFilesTableViewCell).configure(product!.files!)
        case .notesHeading:
            cell = tableView.dequeueReusableCell(withIdentifier: "ProductHeadingTableViewCell", for: indexPath) as! ProductsDetailHeadingTableViewCell
            (cell as! ProductsDetailHeadingTableViewCell).configure("Notes")
        case .notes:
            cell = tableView.dequeueReusableCell(withIdentifier: "ProductLicensingTableViewCell", for: indexPath) as! ProductsDetailLicensingTableViewCell
            (cell as! ProductsDetailLicensingTableViewCell).configure(product!.licensing!)
        }
        
        return cell!
    }
    
    // MARK: Scroll View Delegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y: CGFloat = -tableView.contentOffset.y
        if y > 0 {
            imageView!.frame = CGRect(x: 0, y: tableView.contentOffset.y, width: tableView.bounds.width + y, height: 150 + y)
            imageView!.center = CGPoint(x: view.center.x, y: imageView!.center.y)
        }
    }


}
