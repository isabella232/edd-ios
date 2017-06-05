//
//  ProductsDetailViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 23/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import AlamofireImage
import SwiftyJSON
import SafariServices

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ProductsDetailViewController: SiteTableViewController, UITextViewDelegate {

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
    var fetchedProduct: JSON?
    var imageView: UIImageView?
    
    init(product: Product) {
        super.init(style: .plain)
        
        self.site = Site.activeSite()
        self.product = product
        
        title = product.title
        
        view.backgroundColor = .EDDGreyColor()
        
        networkOperations()

        let uiBusy = UIActivityIndicatorView(activityIndicatorStyle: .white)
        uiBusy.hidesWhenStopped = true
        uiBusy.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: uiBusy)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.register(ProductsDetailHeadingTableViewCell.self, forCellReuseIdentifier: "ProductHeadingTableViewCell")
        tableView.register(ProductsDetailInfoTableViewCell.self, forCellReuseIdentifier: "ProductInfoTableViewCell")
        tableView.register(ProductsDetailStatsTableViewCell.self, forCellReuseIdentifier: "ProductStatsTableViewCell")
        tableView.register(ProductsDetailPricingTableViewCell.self, forCellReuseIdentifier: "ProductPricingTableViewCell")
        tableView.register(ProductsDetailLicensingTableViewCell.self, forCellReuseIdentifier: "ProductLicensingTableViewCell")
        tableView.register(ProductsDetailFilesTableViewCell.self, forCellReuseIdentifier: "ProductFilesTableViwCell")
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(product.title)
        navigationItem.titleView = titleLabel
        
        cells = [.infoHeading, .info, .statsHeading, .stats, .pricingHeading, .pricing]
        
        if product.files != nil {
            cells.append(.filesHeading)
            cells.append(.files)
        }
        
        if product.notes?.characters.count > 0 {
            cells.append(.notesHeading)
            cells.append(.notes)
        }
        
        if product.licensing != nil {
            cells.append(.licensingHeading)
            cells.append(.licensing)
        }
        
        if let thumbnail = product.thumbnail {
            if thumbnail.characters.count > 0 && thumbnail != "false" {
                setupHeaderView()
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Private
    
    fileprivate func setupHeaderView() {
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 150))
        imageView!.contentMode = .scaleAspectFill
        
        let url = URL(string: product!.thumbnail!)
        imageView!.af_setImage(withURL: url!, placeholderImage: nil, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: true, completion: nil)
        
        tableView.addSubview(imageView!)
        tableView.sendSubview(toBack: imageView!)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 150))
    }
    
    fileprivate func networkOperations() {
        guard product != nil else {
            return
        }
        
        let productRecord = Product.fetchSingleObjectInContext(AppDelegate.sharedInstance.managedObjectContext) { (request) in
            request.predicate = Product.predicateForId(self.product!.pid)
            request.fetchLimit = 1
        }
        
        EDDAPIWrapper.sharedInstance.requestProducts(["product": "\(product!.pid)" as AnyObject], success: { (json) in
            if let items = json["products"].array {
                self.fetchedProduct = items[0]
                
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
                if item["pricing"].dictionary?.count > 1 {
                    hasVariablePricing = true
                }
                
                let pricing = NSKeyedArchiver.archivedData(withRootObject: item["pricing"].dictionaryObject!)
                
                if productRecord != nil {
                    productRecord!.setValue(stats! as Data, forKey: "stats")
                    productRecord!.setValue(notes, forKey: "notes")
                    productRecord!.setValue(pricing, forKey: "pricing")
                    if let files_ = files {
                        productRecord!.setValue(files_ as Data, forKey: "files")
                    }
                    productRecord!.setValue(item["info"]["title"].stringValue, forKey: "title")
                    productRecord!.setValue(item["licensing"].dictionaryObject! as [String : AnyObject], forKey: "licensing")
                    productRecord!.setValue(hasVariablePricing as NSNumber, forKey: "hasVariablePricing")
                    productRecord!.setValue(item["info"]["thumbnail"].stringValue, forKey: "thumbnail")
                }
                
                DispatchQueue.main.async(execute: {
                    do {
                        try AppDelegate.sharedInstance.managedObjectContext.save()
                        self.tableView.reloadData()

                        self.navigationItem.rightBarButtonItem = nil
                    } catch {
                        print("Unable to save context")
                    }
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
        return cells.count
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
                (cell as! ProductsDetailFilesTableViewCell).filesLabel.delegate = self
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
            if let thumbnail = self.product!.thumbnail {
                if thumbnail.characters.count > 0 && thumbnail != "false" {
                    imageView!.frame = CGRect(x: 0, y: tableView.contentOffset.y, width: tableView.bounds.width + y, height: 150 + y)
                    imageView!.center = CGPoint(x: view.center.x, y: imageView!.center.y)
                }
            }
        }
    }
    
    // MARK: Text View Delegate
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        let svc = SFSafariViewController(url: URL)
        if #available(iOS 10.0, *) {
            svc.preferredBarTintColor = .EDDBlackColor()
            svc.preferredControlTintColor = .white
        } else {
            svc.view.tintColor = .EDDBlueColor()
        }
        svc.modalPresentationStyle = .overCurrentContext
        self.present(svc, animated: true, completion: nil)
        return false
    }
    
}
