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


class SalesFilterTableViewController: SiteTableViewController, UpdateDateCellDelegate {

    private var startDateIndexPath: NSIndexPath!
    private var endDateIndexPath: NSIndexPath!
    
    private var dates: [String] = [sharedDateFormatter.stringFromDate(NSDate()), sharedDateFormatter.stringFromDate(NSDate())]
    private var message: String = ""
    private var chosenFilter: String = "sales"
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .EDDGreyColor()
        
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.registerClass(SalesFilterDatePickerTableViewCell.self, forCellReuseIdentifier: "SalesFilterDatePickerTableViewCell")
        
        title = NSLocalizedString("Filter Sales/Earnings", comment: "Filter Sales/Earnings title")
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(NSLocalizedString("Filter Sales", comment: "Filter Sales title"))
        navigationItem.titleView = titleLabel
        
        let closeButton = UIBarButtonItem(title: NSLocalizedString("Close", comment: ""), style: .Done, target: self, action: #selector(SalesFilterTableViewController.closeButtonPressed))
        navigationItem.leftBarButtonItem = closeButton
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
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
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 && (indexPath.row == 1 || indexPath.row == 3) {
            return CGFloat(200)
        }
        
        if indexPath.section == 0 {
            return CGFloat(70)
        }
        
        return CGFloat(44)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return 1
            case 1:
                return 2
            case 2:
                return 6
            default:
                return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return NSLocalizedString("Type", comment: "")
        }
        
        if section == 2 {
            return NSLocalizedString("Date Filter", comment: "")
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 || section == 2 {
            return 50
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 2 && indexPath.row == 4 {
            message = ""
            if dates[0].characters.count > 0 && dates[1].characters.count > 0 {
                let startDate = sharedDateFormatter.dateFromString(dates[0])!
                let endDate = sharedDateFormatter.dateFromString(dates[1])!
                
                navigationController?.pushViewController(SalesFilterFetchViewController(startDate: startDate, endDate: endDate, filter: chosenFilter), animated: true)
            } else {
                message = NSLocalizedString("Please select a start and end date", comment: "")
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                chosenFilter = "sales"
                tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
                
                let nextIndexPath = NSIndexPath(forRow: 1, inSection: 1)
                tableView.cellForRowAtIndexPath(nextIndexPath)?.accessoryType = .None
                
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                
                title = NSLocalizedString("Filter Sales", comment: "")
                
                let titleLabel = ViewControllerTitleLabel()
                titleLabel.setTitle(NSLocalizedString("Filter Sales", comment: "Filter Sales title"))
                navigationItem.titleView = titleLabel
            }
            
            if indexPath.row == 1 {
                chosenFilter = "earnings"
                tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
                
                let previousIndexPath = NSIndexPath(forRow: 0, inSection: 1)
                tableView.cellForRowAtIndexPath(previousIndexPath)?.accessoryType = .None
                
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                
                title = NSLocalizedString("Filter Earnings", comment: "")
                
                let titleLabel = ViewControllerTitleLabel()
                titleLabel.setTitle(NSLocalizedString("Filter Earnings", comment: "Filter Earnings title"))
                navigationItem.titleView = titleLabel
            }
        }
        
        let indexPath = NSIndexPath(forRow: 5, inSection: 2)
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        })
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: Table View Data Source
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
        
        if indexPath.section == 1 {
            let cell: UITableViewCell = UITableViewCell()
            
            cell.backgroundColor = .whiteColor()
            cell.textLabel?.textColor = .EDDBlackColor()
            cell.textLabel?.lineBreakMode = .ByWordWrapping
            cell.textLabel?.numberOfLines = 0
            
            if indexPath.row == 0 {
                cell.textLabel?.text = NSLocalizedString("Sales", comment: "")
                cell.accessoryType = .Checkmark
            } else {
                cell.textLabel?.text = NSLocalizedString("Earnings", comment: "")
            }
            
            return cell
        }
        
        if indexPath.section == 2 && (indexPath.row == 1 || indexPath.row == 3) {
            let cell: SalesFilterDatePickerTableViewCell = tableView.dequeueReusableCellWithIdentifier("SalesFilterDatePickerTableViewCell", forIndexPath: indexPath) as! SalesFilterDatePickerTableViewCell
        
            cell.tag = indexPath.row
            cell.delegate = self
            
            return cell
        } else if indexPath.section == 2 {
            if indexPath.row == 4 {
                let cell: UITableViewCell = UITableViewCell()
                cell.backgroundColor = .whiteColor()
                cell.selectionStyle = .Default
                cell.textLabel?.text = NSLocalizedString("Filter", comment: "")
                cell.textLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
                cell.textLabel?.textColor = .EDDBlackColor()
                cell.textLabel?.textAlignment = .Center
                return cell
            }
            
            if indexPath.row == 5 {
                let cell: UITableViewCell = UITableViewCell()
                cell.backgroundColor = .clearColor()
                cell.selectionStyle = .None
                cell.textLabel?.text = message
                cell.textLabel?.textColor = .EDDBlackColor()
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
            let indexPath = NSIndexPath(forRow: 0, inSection: 2)
            dates[0] = sharedDateFormatter.stringFromDate(date)
            
            tableView.cellForRowAtIndexPath(indexPath)?.detailTextLabel?.text = dates[0]
        }
        
        // End Date
        if tag == 3 {
            let indexPath = NSIndexPath(forRow: 2, inSection: 2)
            dates[1] = sharedDateFormatter.stringFromDate(date)
            
            tableView.cellForRowAtIndexPath(indexPath)?.detailTextLabel?.text = dates[1]
        }
    }

}
