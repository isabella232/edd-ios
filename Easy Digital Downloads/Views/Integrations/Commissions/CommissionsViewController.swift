//
//  CommissionsViewController.swift
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

public struct Commissions {
    var amount: Double!
    var rate: Double!
    var currency: String!
    var renewal: Int64?
    var item: String!
    var date: Date!
    var status: String!
}

class CommissionsViewController: SiteTableViewController {
    
    var commissionsObjects = [Commissions]()
    var filteredCommissionsObjects = [Commissions]()
    
    typealias JSON = SwiftyJSON.JSON
    
    var site: Site?
    var commissions: JSON?
    let sharedCache = Shared.dataCache
    var segmentedControl: UISegmentedControl!
    
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
    
    var lastDownloadedPage = UserDefaults(suiteName: "group.easydigitaldownloads.EDDSalesTracker")!.integer(forKey: "\(String(describing: Site.activeSite().uid))-CommissionsPage") 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedControl = UISegmentedControl(items: [NSLocalizedString("All", comment: ""), NSLocalizedString("Unpaid", comment: ""), NSLocalizedString("Paid", comment: ""), NSLocalizedString("Revoked", comment: "")])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.tintColor = .white
        segmentedControl.autoresizingMask = [.flexibleWidth]
        segmentedControl.frame = CGRect(x: 0, y: 0, width: 400, height: 30)
        segmentedControl.contentMode = .scaleToFill
        segmentedControl.addTarget(self, action: #selector(CommissionsViewController.segmentAction), for: .valueChanged)
        segmentedControl.sizeToFit()
        
        sharedCache.fetch(key: Site.activeSite().uid! + "-Commissions").onSuccess({ result in
            let json = JSON.convertFromData(result)! as JSON
            self.commissions = json
            
            if let revoked = json["revoked"].array {
                for item in revoked {
                    self.commissionsObjects.append(Commissions(amount: item["amount"].doubleValue, rate: item["rate"].doubleValue, currency: item["currency"].stringValue, renewal: item["renewal"].int64, item: item["item"].stringValue, date: sharedDateFormatter.date(from: item["date"].stringValue), status: "revoked"))
                }
            }
            
            if let paid = json["paid"].array {
                for item in paid {
                    self.commissionsObjects.append(Commissions(amount: item["amount"].doubleValue, rate: item["rate"].doubleValue, currency: item["currency"].stringValue, renewal: item["renewal"].int64, item: item["item"].stringValue, date: sharedDateFormatter.date(from: item["date"].stringValue), status: "paid"))
                }
            }
            
            if let unpaid = json["unpaid"].array {
                for item in unpaid {
                    self.commissionsObjects.append(Commissions(amount: item["amount"].doubleValue, rate: item["rate"].doubleValue, currency: item["currency"].stringValue, renewal: item["renewal"].int64, item: item["item"].stringValue, date: sharedDateFormatter.date(from: item["date"].stringValue), status: "unpaid"))
                }
            }
            
            self.commissionsObjects.sort(by: { $0.date.compare($1.date) == ComparisonResult.orderedDescending })
            self.filteredCommissionsObjects = self.commissionsObjects
            
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        })
        
        navigationItem.titleView = segmentedControl

        setupInfiniteScrollView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    init(site: Site) {
        super.init(style: .plain)
        
        self.site = site
        
        title = NSLocalizedString("Commissions", comment: "Commissions title")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 85.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        networkOperations()
    }
    
    fileprivate func networkOperations() {
        EDDAPIWrapper.sharedInstance.requestCommissions([ : ], success: { (json) in
            self.sharedCache.set(value: json.asData(), key: Site.activeSite().uid! + "-Commissions")
            
            self.commissionsObjects.removeAll(keepingCapacity: false)
            
            if let revoked = json["revoked"].array {
                for item in revoked {
                    self.commissionsObjects.append(Commissions(amount: item["amount"].doubleValue, rate: item["rate"].doubleValue, currency: item["currency"].stringValue, renewal: item["renewal"].int64, item: item["item"].stringValue, date: sharedDateFormatter.date(from: item["date"].stringValue), status: "revoked"))
                }
            }
            
            if let paid = json["paid"].array {
                for item in paid {
                    self.commissionsObjects.append(Commissions(amount: item["amount"].doubleValue, rate: item["rate"].doubleValue, currency: item["currency"].stringValue, renewal: item["renewal"].int64, item: item["item"].stringValue, date: sharedDateFormatter.date(from: item["date"].stringValue), status: "paid"))
                }
            }
            
            if let unpaid = json["unpaid"].array {
                for item in unpaid {
                    self.commissionsObjects.append(Commissions(amount: item["amount"].doubleValue, rate: item["rate"].doubleValue, currency: item["currency"].stringValue, renewal: item["renewal"].int64, item: item["item"].stringValue, date: sharedDateFormatter.date(from: item["date"].stringValue), status: "unpaid"))
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
        navigationController?.pushViewController(CommissionsDetailViewController(commission: filteredCommissionsObjects[indexPath.row]), animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Table View Delegate

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: CommissionsTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "CommissionsCell") as! CommissionsTableViewCell?
        
        if cell == nil {
            cell = CommissionsTableViewCell()
        }
        
        cell?.configure(filteredCommissionsObjects[indexPath.row])
        
        return cell!
    }
    
    // MARK: Segmented Control
    
    func segmentAction() {
        switch segmentedControl.selectedSegmentIndex {
            case 0:
                self.filteredCommissionsObjects = self.commissionsObjects
                reload()
            case 1:
                self.filteredCommissionsObjects = self.commissionsObjects.filter({ $0.status == "unpaid" })
                reload()
            case 2:
                self.filteredCommissionsObjects = self.commissionsObjects.filter({ $0.status == "paid" })
                reload()
            case 3:
                self.filteredCommissionsObjects = self.commissionsObjects.filter({ $0.status == "revoked" })
                reload()
            default:
                self.filteredCommissionsObjects = self.commissionsObjects
                reload()
        }
    }
    
    fileprivate func reload() {
        DispatchQueue.main.async { 
            self.tableView.reloadData()
        }
    }
    
}

extension CommissionsViewController : InfiniteScrollingTableView {
    
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
