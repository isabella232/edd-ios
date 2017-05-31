//
//  StoreCommissionsViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 29/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
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

public struct StoreCommissions {
    var amount: Double!
    var rate: Double!
    var currency: String!
    var renewal: Int64?
    var item: String!
    var date: Date!
    var status: String!
}

class StoreCommissionsViewController: SiteTableViewController {

    var commissionsObjects = [StoreCommissions]()
    var filteredCommissionsObjects = [StoreCommissions]()
    
    typealias JSON = SwiftyJSON.JSON
    
    var site: Site?
    var commissions: JSON?
    let sharedCache = Shared.dataCache
    
    var hasMoreCommissions: Bool = true {
        didSet {
            if (!hasMoreCommissions) {
                activityIndicatorView.stopAnimating()
            } else {
                activityIndicatorView.startAnimating()
            }
        }
    }
    
    let sharedDefaults: UserDefaults = UserDefaults(suiteName: "group.easydigitaldownloads.EDDSalesTracker")!
    
    var lastDownloadedPage = UserDefaults(suiteName: "group.easydigitaldownloads.EDDSalesTracker")!.integer(forKey: "\(String(describing: Site.activeSite().uid))-StoreCommissionsPage")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sharedCache.fetch(key: Site.activeSite().uid! + "-StoreCommissions").onSuccess({ result in
            let json = JSON.convertFromData(result)! as JSON
            self.commissions = json
            
            if let items = json["commissions"].array {
                for item in items {
                    self.commissionsObjects.append(StoreCommissions(amount: item["amount"].doubleValue, rate: item["rate"].doubleValue, currency: item["currency"].stringValue, renewal: item["renewal"].int64, item: item["item"].stringValue, date: sharedDateFormatter.date(from: item["date"].stringValue), status: item["status"].stringValue))
                }
            }
            
            self.commissionsObjects.sort(by: { $0.date.compare($1.date) == ComparisonResult.orderedDescending })
            self.filteredCommissionsObjects = self.commissionsObjects
            
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        })
        
        setupInfiniteScrollView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    init(site: Site) {
        super.init(style: .plain)
        
        self.site = site
        
        title = NSLocalizedString("Store Commissions", comment: "Store Commissions title")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 85.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(NSLocalizedString("Store Commissions", comment: "Store Commissions title"))
        navigationItem.titleView = titleLabel
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        networkOperations()
    }
    
    fileprivate func networkOperations() {
        EDDAPIWrapper.sharedInstance.requestStoreCommissions([ : ], success: { (json) in
            self.sharedCache.set(value: json.asData(), key: Site.activeSite().uid! + "-StoreCommissions")
            
            self.commissionsObjects.removeAll(keepingCapacity: false)
            
            if let items = json["commissions"].array {
                for item in items {
                    self.commissionsObjects.append(StoreCommissions(amount: item["amount"].doubleValue, rate: item["rate"].doubleValue, currency: item["currency"].stringValue, renewal: item["renewal"].int64, item: item["item"].stringValue, date: sharedDateFormatter.date(from: item["date"].stringValue), status: item["status"].stringValue))
                }
            }
            
            self.commissionsObjects.sort(by: { $0.date.compare($1.date) == ComparisonResult.orderedDescending })
            self.filteredCommissionsObjects = self.commissionsObjects
            
            DispatchQueue.main.async(execute: { 
                self.tableView.reloadData()
            })
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    fileprivate func requestNextPage() {
        //        EDDAPIWrapper.sharedInstance.requestSales([ "page": lastDownloadedPage ], success: { (json) in
        //            if let items = json["sales"].array {
        //                if items.count == 20 {
        //                    self.hasMoreSales = true
        //                } else {
        //                    self.hasMoreSales = false
        //                }
        //                for item in items {
        //                    self.sales?.append(item)
        //                }
        //                self.updateLastDownloadedPage()
        //            }
        //
        //        }) { (error) in
        //            print(error.localizedDescription)
        //        }
    }
    
    fileprivate func updateLastDownloadedPage() {
        self.lastDownloadedPage = self.lastDownloadedPage + 1;
        sharedDefaults.set(lastDownloadedPage, forKey: "\(String(describing: Site.activeSite().uid))-CommissionsPage")
        sharedDefaults.synchronize()
    }
    
    // MARK: Scroll View Delegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let actualPosition: CGFloat = scrollView.contentOffset.y
        let contentHeight: CGFloat = scrollView.contentSize.height - tableView.frame.size.height;
        
        if actualPosition >= contentHeight {
            self.requestNextPage()
        }
    }
    
    // MARK: Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredCommissionsObjects.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(StoreCommissionsDetailViewController(storeCommission: filteredCommissionsObjects[indexPath.row]), animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: StoreCommissionsTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "StoreCommissionsCell") as! StoreCommissionsTableViewCell?
        
        if cell == nil {
            cell = StoreCommissionsTableViewCell()
        }
        
        cell?.configure(filteredCommissionsObjects[indexPath.row])
        
        return cell!
    }

}

extension StoreCommissionsViewController : InfiniteScrollingTableView {
    
    func setupInfiniteScrollView() {
        let bounds = UIScreen.main.bounds
        let width = bounds.size.width
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 44))
        footerView.backgroundColor = .clear
        
        activityIndicatorView.startAnimating()
        
        footerView.addSubview(activityIndicatorView)
        
        tableView.tableFooterView = footerView
    }
    
}
