//
//  SalesFilterTableViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 29/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

private let sharedDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateStyle = .ShortStyle
    return formatter
}()


class SalesFilterTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UpdateDateCellDelegate {

    private var tableView: UITableView!
    private var navigationBar: UINavigationBar!
    
    private var startDateIndexPath: NSIndexPath!
    private var endDateIndexPath: NSIndexPath!
    
    private var dates: [String] = ["", ""]
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar = UINavigationBar(frame: CGRectMake(0, 0, view.frame.width, 64))
        navigationBar.translucent = false
        navigationBar.barStyle = .Black
        
        tableView = UITableView(frame: CGRectMake(0, navigationBar.frame.height, view.frame.width, view.frame.height - navigationBar.frame.height) ,style: .Plain);
        tableView.scrollEnabled = true
        tableView.bounces = true
        tableView.showsVerticalScrollIndicator = true
        tableView.userInteractionEnabled = true
        tableView.backgroundColor = .clearColor()
        tableView.separatorColor = UIColor.separatorColor()
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.registerClass(SalesFilterDatePickerTableViewCell.self, forCellReuseIdentifier: "SalesFilterDatePickerTableViewCell")
        
        title = NSLocalizedString("Filter Sales", comment: "")

        
        let navigationItem = UINavigationItem(title: NSLocalizedString("Filter Sales", comment: ""))
        let closeButton = UIBarButtonItem(title: NSLocalizedString("Close", comment: ""), style: .Plain, target: self, action: #selector(SalesFilterTableViewController.closeButtonPressed))
        navigationItem.leftBarButtonItem = closeButton
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(NSLocalizedString("Filter Sales", comment: "Sales title"))
        navigationItem.titleView = titleLabel
        navigationBar.items = [navigationItem]
        
        view.addSubview(tableView)
        view.addSubview(navigationBar)
    }
    
    func closeButtonPressed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    // MARK: Table View Delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 && (indexPath.row == 1 || indexPath.row == 3) {
            return CGFloat(200)
        }
        
        if indexPath.section == 0 {
            return CGFloat(70)
        }
        
        return CGFloat(44)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return 1
            case 1:
                return 5
            default:
                return 0
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return NSLocalizedString("Date Filter", comment: "")
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view: UIView = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 40))
        view.backgroundColor = .EDDGreyColor()
        view.userInteractionEnabled = false
        view.tag = section
        
        let label = UILabel(frame: CGRectMake(15, 25, tableView.bounds.size.width - 10, 20))
        label.text = self.tableView(tableView, titleForHeaderInSection: section)?.uppercaseString
        label.textColor = .EDDBlackColor()
        label.font = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
        label.textAlignment = .Left
        
        view.addSubview(label)
        
        return view
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 50
        }
        
        return 0
    }
    
    // MARK: Table View Data Source
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: UITableViewCell = UITableViewCell()
            
            cell.selectionStyle = .None
            cell.backgroundColor = .clearColor()
            cell.textLabel?.text = "Set a start and end date to view sales between a certain time period"
            cell.textLabel?.textColor = .EDDBlackColor()
            cell.textLabel?.lineBreakMode = .ByWordWrapping
            cell.textLabel?.numberOfLines = 0
            
            return cell
        }
        
        if indexPath.section == 1 && (indexPath.row == 1 || indexPath.row == 3) {
            let cell: SalesFilterDatePickerTableViewCell = tableView.dequeueReusableCellWithIdentifier("SalesFilterDatePickerTableViewCell", forIndexPath: indexPath) as! SalesFilterDatePickerTableViewCell
        
            cell.tag = indexPath.row
            cell.delegate = self
            
            return cell
        } else if indexPath.section == 1 {
            if indexPath.row == 4 {
                let cell: UITableViewCell = UITableViewCell()
                cell.backgroundColor = .whiteColor()
                cell.selectionStyle = .Default
                cell.textLabel?.text = NSLocalizedString("Filter", comment: "")
                cell.textLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
                cell.textLabel?.textAlignment = .Center
                return cell
            }
            
            let cell: UITableViewCell = UITableViewCell(style: .Value1, reuseIdentifier: "StaticCell")
            cell.backgroundColor = .whiteColor()
            cell.textLabel?.textColor = .EDDBlackColor()
            cell.selectionStyle = .None
            
            if indexPath.row == 0 {
                cell.textLabel?.text = NSLocalizedString("Start Date", comment: "")
                cell.detailTextLabel?.text = dates[0]
            }
            
            if indexPath.row == 2 {
                cell.textLabel?.text = NSLocalizedString("End Date", comment: "")
                cell.detailTextLabel?.text = dates[1]
            }
            
            return cell
        }
        
        let cell: UITableViewCell = UITableViewCell()
        return cell
    }
    
    // MARK: UpdateDataCellDelegate
    
    func sendDate(date: NSDate, tag: Int) {
        // Start Date
        if tag == 1 {
            let indexPath = NSIndexPath(forRow: 0, inSection: 1)
            dates[0] = sharedDateFormatter.stringFromDate(date)
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            })
        }
        
        // End Date
        if tag == 3 {
            let indexPath = NSIndexPath(forRow: 2, inSection: 1)
            dates[1] = sharedDateFormatter.stringFromDate(date)
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            })
        }
    }

}
