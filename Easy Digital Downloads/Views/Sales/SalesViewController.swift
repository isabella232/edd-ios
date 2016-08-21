//
//  SalesViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 28/05/2016.
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

class SalesViewController: UITableViewController {

    var managedObjectContext: NSManagedObjectContext!

    var site: Site?
    var sales: [JSON]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    init(site: Site) {
        super.init(style: .Plain)
        
        self.site = site
        self.managedObjectContext = AppDelegate.sharedInstance.managedObjectContext
        
        title = NSLocalizedString("Sales", comment: "Sales title")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        sales = [JSON]()
        
//        EDDAPIWrapper.sharedInstance.requestSales([ : ], success: { (json) in
//            if let items = json["sales"].array {
//                self.sales = items
//                self.persistSales()
//            }
//
//            }) { (error) in
//                fatalError()
//        }
    }
    
    private func persistSales() {
        guard let sales_ = sales else {
            return
        }
        
        for item in sales_ {
            Sale.insertIntoContext(managedObjectContext, date: sharedDateFormatter.dateFromString(item["date"].stringValue)!, email: item["email"].stringValue, fees: item["fees"].dictionaryObject, gateway: item["gateway"].stringValue, key: item["key"].stringValue, sid: Int16(item["ID"].stringValue)!, subtotal: NSNumber(double: item["subtotal"].doubleValue).doubleValue, tax: NSNumber(double: item["tax"].doubleValue).doubleValue, total: NSNumber(double: item["total"].doubleValue).doubleValue, transactionId: item["transaction_id"].stringValue)
        }
        
        do {
            try managedObjectContext.save()
            managedObjectContext.processPendingChanges()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    // MARK: Private
    
    private typealias Data = FetchedResultsDataProvider<SalesViewController>
    private var dataSource: TableViewDataSource<SalesViewController, Data, SalesTableViewCell>!
    
    private func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.registerClass(SalesTableViewCell.self, forCellReuseIdentifier: "SaleCell")
        setupDataSource()
    }
    
    private func setupDataSource() {
        let request = Sale.defaultFetchRequest()
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        let dataProvider = FetchedResultsDataProvider(fetchedResultsController: frc, delegate: self)
        dataSource = TableViewDataSource(tableView: tableView, dataProvider: dataProvider, delegate: self)
    }
    
}

extension SalesViewController: DataProviderDelegate {

    func dataProviderDidUpdate(updates: [DataProviderUpdate<Sale>]?) {
        dataSource.processUpdates(updates)
    }

}

extension SalesViewController: DataSourceDelegate {
    
    func cellIdentifierForObject(object: Sale) -> String {
        return "SaleCell"
    }
    
}