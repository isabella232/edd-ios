//
//  SalesFilterTableViewController.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 29/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

private let sharedDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()


class SalesFilterTableViewController: SiteTableViewController, UpdateDateCellDelegate {

    fileprivate var startDateIndexPath: IndexPath!
    fileprivate var endDateIndexPath: IndexPath!
    
    fileprivate var dates: [String] = [sharedDateFormatter.string(from: Date()), sharedDateFormatter.string(from: Date())]
    fileprivate var message: String = ""
    fileprivate var chosenFilter: String = "sales"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .EDDGreyColor()
        
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.register(SalesFilterDatePickerTableViewCell.self, forCellReuseIdentifier: "SalesFilterDatePickerTableViewCell")
        
        title = NSLocalizedString("Filter Sales/Earnings", comment: "Filter Sales/Earnings title")
        
        let titleLabel = ViewControllerTitleLabel()
        titleLabel.setTitle(NSLocalizedString("Filter Sales", comment: "Filter Sales title"))
        navigationItem.titleView = titleLabel
        
        let closeButton = UIBarButtonItem(title: NSLocalizedString("Close", comment: ""), style: .done, target: self, action: #selector(SalesFilterTableViewController.closeButtonPressed))
        navigationItem.leftBarButtonItem = closeButton
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func closeButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    // MARK: Table View Delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && (indexPath.row == 1 || indexPath.row == 3) {
            return CGFloat(200)
        }
        
        if indexPath.section == 0 {
            return CGFloat(70)
        }
        
        return CGFloat(44)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return NSLocalizedString("Type", comment: "")
        }
        
        if section == 2 {
            return NSLocalizedString("Date Filter", comment: "")
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view: UIView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 40))
        view.backgroundColor = .EDDGreyColor()
        view.isUserInteractionEnabled = false
        view.tag = section
        
        let label = UILabel(frame: CGRect(x: 15, y: 25, width: tableView.bounds.size.width - 10, height: 20))
        label.text = self.tableView(tableView, titleForHeaderInSection: section)?.uppercased()
        label.textColor = .EDDBlackColor()
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight)
        label.textAlignment = .left
        
        view.addSubview(label)
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 || section == 2 {
            return 50
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row == 4 {
            message = ""
            if dates[0].characters.count > 0 && dates[1].characters.count > 0 {
                let startDate = sharedDateFormatter.date(from: dates[0])!
                let endDate = sharedDateFormatter.date(from: dates[1])!
                
                navigationController?.pushViewController(SalesFilterFetchViewController(startDate: startDate, endDate: endDate, filter: chosenFilter), animated: true)
            } else {
                message = NSLocalizedString("Please select a start and end date", comment: "")
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                chosenFilter = "sales"
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                
                let nextIndexPath = IndexPath(row: 1, section: 1)
                tableView.cellForRow(at: nextIndexPath)?.accessoryType = .none
                
                tableView.deselectRow(at: indexPath, animated: true)
                
                title = NSLocalizedString("Filter Sales", comment: "")
                
                let titleLabel = ViewControllerTitleLabel()
                titleLabel.setTitle(NSLocalizedString("Filter Sales", comment: "Filter Sales title"))
                navigationItem.titleView = titleLabel
            }
            
            if indexPath.row == 1 {
                chosenFilter = "earnings"
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                
                let previousIndexPath = IndexPath(row: 0, section: 1)
                tableView.cellForRow(at: previousIndexPath)?.accessoryType = .none
                
                tableView.deselectRow(at: indexPath, animated: true)
                
                title = NSLocalizedString("Filter Earnings", comment: "")
                
                let titleLabel = ViewControllerTitleLabel()
                titleLabel.setTitle(NSLocalizedString("Filter Earnings", comment: "Filter Earnings title"))
                navigationItem.titleView = titleLabel
            }
        }
        
        let indexPath = IndexPath(row: 5, section: 2)
        DispatchQueue.main.async(execute: {
            self.tableView.reloadRows(at: [indexPath], with: .none)
        })
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Table View Data Source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: UITableViewCell = UITableViewCell()
            
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            cell.textLabel?.text = "Set a start and end date to view sales between a certain time period"
            cell.textLabel?.textColor = .EDDBlackColor()
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.textLabel?.numberOfLines = 0
            
            return cell
        }
        
        if indexPath.section == 1 {
            let cell: UITableViewCell = UITableViewCell()
            
            cell.backgroundColor = .white
            cell.textLabel?.textColor = .EDDBlackColor()
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.textLabel?.numberOfLines = 0
            
            if indexPath.row == 0 {
                cell.textLabel?.text = NSLocalizedString("Sales", comment: "")
                cell.accessoryType = .checkmark
            } else {
                cell.textLabel?.text = NSLocalizedString("Earnings", comment: "")
            }
            
            return cell
        }
        
        if indexPath.section == 2 && (indexPath.row == 1 || indexPath.row == 3) {
            let cell: SalesFilterDatePickerTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SalesFilterDatePickerTableViewCell", for: indexPath) as! SalesFilterDatePickerTableViewCell
        
            cell.tag = indexPath.row
            cell.delegate = self
            
            return cell
        } else if indexPath.section == 2 {
            if indexPath.row == 4 {
                let cell: UITableViewCell = UITableViewCell()
                cell.backgroundColor = .white
                cell.selectionStyle = .default
                cell.textLabel?.text = NSLocalizedString("Filter", comment: "")
                cell.textLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
                cell.textLabel?.textColor = .EDDBlackColor()
                cell.textLabel?.textAlignment = .center
                return cell
            }
            
            if indexPath.row == 5 {
                let cell: UITableViewCell = UITableViewCell()
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                cell.textLabel?.text = message
                cell.textLabel?.textColor = .EDDBlackColor()
                cell.textLabel?.textAlignment = .center
                return cell
            }
            
            let cell: UITableViewCell = UITableViewCell(style: .value1, reuseIdentifier: "StaticCell")
            cell.backgroundColor = .white
            cell.textLabel?.textColor = .EDDBlackColor()
            cell.selectionStyle = .none
            
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
    
    func sendDate(_ date: Date, tag: Int) {
        // Start Date
        if tag == 1 {
            let indexPath = IndexPath(row: 0, section: 2)
            dates[0] = sharedDateFormatter.string(from: date)
            
            tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = dates[0]
        }
        
        // End Date
        if tag == 3 {
            let indexPath = IndexPath(row: 2, section: 2)
            dates[1] = sharedDateFormatter.string(from: date)
            
            tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = dates[1]
        }
    }

}
