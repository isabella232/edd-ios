//
//  CommissionsDetailViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 29/09/2016.
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

class CommissionsDetailViewController: SiteTableViewController {

    fileprivate enum CellType {
        case metaHeading
        case meta
    }
    
    fileprivate var cells = [CellType]()
    
    var site: Site?
    var commission: Commissions?
    
    init(commission: Commissions) {
        super.init(style: .plain)
        
        self.site = Site.activeSite()
        self.commission = commission
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(NSLocalizedString("Commission", comment: ""))
        navigationItem.titleView = titleLabel
        
        tableView.register(CommissionsDetailHeadingTableViewCell.self, forCellReuseIdentifier: "CommissionsDetailHeadingTableViewCell")
        tableView.register(CommissionsDetailMetaTableViewCell.self, forCellReuseIdentifier: "CommissionsDetailMetaTableViewCell")
        
        cells = [.metaHeading, .meta]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
                cell = tableView.dequeueReusableCell(withIdentifier: "CommissionsDetailHeadingTableViewCell", for: indexPath) as! CommissionsDetailHeadingTableViewCell
                (cell as! CommissionsDetailHeadingTableViewCell).configure("Meta")
            case .meta:
                cell = tableView.dequeueReusableCell(withIdentifier: "CommissionsDetailMetaTableViewCell", for: indexPath) as! CommissionsDetailMetaTableViewCell
                (cell as! CommissionsDetailMetaTableViewCell).configure(self.commission!)
        }
        
        return cell!
    }
    
}
