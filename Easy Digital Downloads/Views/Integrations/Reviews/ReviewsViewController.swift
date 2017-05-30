//
//  ReviewsViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 22/08/2016.
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

public struct Review {
    var ID: Int64!
    var title: String!
    var parent: Int64!
    var downloadId: Int64!
    var rating: Int64!
    var author: String!
    var email: String!
    var IP: String!
    var date: Date!
    var content: String!
    var status: String!
    var userId: Int64!
    var type: String!
    var isReply: Bool!
    var votes: [String: SwiftyJSON.JSON]!
}

class ReviewsViewController: SiteTableViewController {

    var reviewObjects = [Review]()
    
    typealias JSON = SwiftyJSON.JSON
    
    var site: Site?
    var reviews: JSON?
    let sharedCache = Shared.dataCache
    
    var hasMoreReviews: Bool = true {
        didSet {
            if (!hasMoreReviews) {
                activityIndicatorView.stopAnimating()
            } else {
                activityIndicatorView.startAnimating()
            }
        }
    }
    
    let sharedDefaults: UserDefaults = UserDefaults(suiteName: "group.easydigitaldownloads.EDDSalesTracker")!
    
    var lastDownloadedPage = UserDefaults(suiteName: "group.easydigitaldownloads.EDDSalesTracker")!.integer(forKey: "\(Site.activeSite().uid)-ReviewsPage") ?? 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sharedCache.fetch(key: Site.activeSite().uid! + "-Reviews").onSuccess({ result in
            let json = JSON.convertFromData(result)! as JSON
            self.reviews = json
            
            if let items = json["reviews"]["most_recent"].array {
                for item in items {
                    let reply = (item["type"].stringValue == "reply" ? true : false)
                    
                    self.reviewObjects.append(Review(ID: item["ID"].int64Value, title: item["title"].stringValue, parent: item["parent"].int64Value, downloadId: item["download_id"].int64Value, rating: item["rating"].int64Value, author: item["author"].stringValue, email: item["email"].stringValue, IP: item["IP"].stringValue, date: sharedDateFormatter.dateFromString(item["date"].stringValue), content: item["content"].stringValue, status: item["status"].stringValue, userId: item["user_id"].int64Value, type: item["type"].stringValue, isReply: reply, votes: item["votes"].dictionaryValue))
                }
            }
            
            self.reviewObjects.sortInPlace({ $0.ID < $1.ID })
            
            dispatch_async(dispatch_get_main_queue(), {
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
        
        title = NSLocalizedString("Reviews", comment: "Reviews title")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 85.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(NSLocalizedString("Reviews", comment: "Reviews title"))
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
        EDDAPIWrapper.sharedInstance.requestReviews([ : ], success: { (result) in
            self.sharedCache.set(value: result.asData(), key: Site.activeSite().uid! + "-Reviews")
            
            self.reviewObjects.removeAll(keepCapacity: false)
            
            if let items = result["reviews"]["most_recent"].array {
                for item in items {
                    let reply = (item["type"].stringValue == "reply" ? true : false)
                    
                    self.reviewObjects.append(Review(ID: item["ID"].int64Value, title: item["title"].stringValue, parent: item["parent"].int64Value, downloadId: item["download_id"].int64Value, rating: item["rating"].int64Value, author: item["author"].stringValue, email: item["email"].stringValue, IP: item["IP"].stringValue, date: sharedDateFormatter.dateFromString(item["date"].stringValue), content: item["content"].stringValue, status: item["status"].stringValue, userId: item["user_id"].int64Value, type: item["type"].stringValue, isReply: reply, votes: item["votes"].dictionaryValue))
                }
            }
            
            self.reviewObjects.sortInPlace({ $0.ID < $1.ID })
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    fileprivate func requestNextPage() {
        
    }
    
    fileprivate func updateLastDownloadedPage() {
        self.lastDownloadedPage = self.lastDownloadedPage + 1;
        sharedDefaults.set(lastDownloadedPage, forKey: "\(Site.activeSite().uid)-ReviewsPage")
        sharedDefaults.synchronize()
    }
    
    // MARK: Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reviewObjects.count ?? 0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let review = reviewObjects[indexPath.row]
        
        navigationController?.pushViewController(ReviewsDetailViewController(review: review), animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: ReviewsTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "ReviewsTableViewCell") as! ReviewsTableViewCell?
        
        if cell == nil {
            cell = ReviewsTableViewCell()
        }
        
        cell?.configure(reviewObjects[indexPath.row])
        
        return cell!
    }

}

extension ReviewsViewController : InfiniteScrollingTableView {

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
