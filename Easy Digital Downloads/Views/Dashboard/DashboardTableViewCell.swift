//
//  DashboardTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 29/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import SwiftyJSON
import BEMSimpleLineGraph

enum DashboardCell: Int {
    case sales = 1
    case earnings = 2
    case commissions = 3
    case storeCommissions = 4
    case reviews = 5
    case none = 6
    
    func label() -> String {
        switch self {
            case .sales: return "Sales Today"
            case .earnings: return "Earning Today"
            case .commissions: return "Commissions"
            case .storeCommissions: return "Store Commissions"
            case .reviews: return "Reviews"
            case .none: return "None"
        }
    }
}

class DashboardTableViewCell: UITableViewCell, BEMSimpleLineGraphDelegate, BEMSimpleLineGraphDataSource {
    var hasSetupConstraints = false
    var data: NSArray?
    
    fileprivate var type: DashboardCell = .none
    
    lazy var stackView : UIStackView! = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 3.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        return stack
    }()
    
    lazy var topStackView : UIStackView! = {
        let stack = UIStackView()
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        return stack
    }()
    
    lazy var middleStackView : UIStackView! = {
        let stack = UIStackView()
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 3.0
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        return stack
    }()
    
    lazy var containerView: UIView! = {
        let view = UIView()
        view.backgroundColor = .EDDBlueColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = false
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 3
        view.layer.shadowOpacity = 0.4
        view.layer.shadowColor = UIColor.black.cgColor
        return view
    }()
    
    fileprivate var _title: String = ""
    fileprivate var _stat: String = ""
    fileprivate var _salesData: Array<Int>?
    fileprivate var _earningsData: Array<Double>?
    fileprivate var _dates: Array<String>?
    
    fileprivate let site: Site = Site.activeSite()
    
    var title:String {
        get {
            return _title
        }
        set {
            _title = newValue
            self.titleLabel.text = _title
        }
    }

    var stat:String {
        get {
            return _stat
        }
        set {
            _stat = newValue
            self.statLabel.text = _stat
        }
    }
    
    let titleLabel = UILabel(frame: CGRect.zero)
    let statLabel = UILabel(frame: CGRect.zero)
    let firstStatLabel = UILabel(frame: CGRect.zero)
    let secondStatLabel = UILabel(frame: CGRect.zero)
    let thirdStatLabel = UILabel(frame: CGRect.zero)
    
    fileprivate var graph: BEMSimpleLineGraphView?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.isOpaque = true
        isOpaque = true
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightLight)
        titleLabel.text = data?.object(at: 1) as? String
        
        statLabel.textColor = .white
        statLabel.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightLight)
        
        firstStatLabel.textColor = .white
        firstStatLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight)
        firstStatLabel.text = "Current Month:"
        
        secondStatLabel.textColor = .white
        secondStatLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight)
        secondStatLabel.text = "Last Month:"
        
        thirdStatLabel.textColor = .white
        thirdStatLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight)
        thirdStatLabel.text = "Total:"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.type = .none
        
        self.graph?.removeFromSuperview()
    }
    
    func layout() {
        topStackView.addArrangedSubview(titleLabel)
        topStackView.addArrangedSubview(statLabel)
        
        if type != .storeCommissions {
            middleStackView.addArrangedSubview(firstStatLabel)
            middleStackView.addArrangedSubview(secondStatLabel)
            middleStackView.addArrangedSubview(thirdStatLabel)
        }
        
        stackView.addArrangedSubview(topStackView)
        stackView.addArrangedSubview(middleStackView)
        
        // Create graphs for Sales and Earnings cells
        let graph = BEMSimpleLineGraphView()
        graph.dataSource = self
        graph.delegate = self
        graph.enableYAxisLabel = true
        graph.autoScaleYAxis = true
        graph.enableReferenceXAxisLines = false
        graph.enableReferenceYAxisLines = true
        graph.enableReferenceAxisFrame = false
        graph.animationGraphStyle = .none
        graph.colorBackgroundXaxis = UIColor.clear
        graph.colorBackgroundYaxis = UIColor.clear
        graph.colorTop = UIColor.clear
        graph.colorBottom = UIColor.clear
        graph.backgroundColor = UIColor.clear
        graph.tintColor = UIColor.clear
        graph.colorYaxisLabel = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.5)
        graph.colorXaxisLabel = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.5)
        graph.alwaysDisplayDots = true
        graph.enablePopUpReport = true
        graph.enableTouchReport = true
        graph.translatesAutoresizingMaskIntoConstraints = false
        self.graph = graph
        
        if type == .commissions || type == .storeCommissions {
            middleStackView.removeArrangedSubview(graph)
            graph.removeFromSuperview()
        } else {
            middleStackView.addArrangedSubview(graph)
            graph.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
            graph.heightAnchor.constraint(equalToConstant: 115).isActive = true
        }
        
        if type == .storeCommissions {
            middleStackView.removeArrangedSubview(firstStatLabel)
            middleStackView.removeArrangedSubview(secondStatLabel)
            middleStackView.removeArrangedSubview(thirdStatLabel)
            
            firstStatLabel.removeFromSuperview()
            secondStatLabel.removeFromSuperview()
            thirdStatLabel.removeFromSuperview()
        }

        containerView.addSubview(stackView)
        
        topStackView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        middleStackView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.alignment = .top
        
        contentView.addSubview(containerView)

        var constraints = [NSLayoutConstraint]()
        constraints.append(containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10))
        constraints.append(containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10))
        constraints.append(containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15))
        constraints.append(containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15))
        constraints.append(stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10))
        constraints.append(stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10))
        constraints.append(stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10))
        constraints.append(stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10))

        NSLayoutConstraint.activate(constraints)
    }
    
    func configure<T>(_ heading: String, stats: Stats?, data: Array<T>, dates: Array<String>) {
        title = heading
        
        guard let cellStats = stats else {
            return
        }
        
        _dates = dates
        
        // Sales
        if heading == "Sales Today" {
            stat = "\(cellStats.sales["today"]!)"
            _salesData = data.map({ Item -> Int in
                return Item as! Int
            })
            type = .sales
            
            firstStatLabel.text = "Current Month: \(cellStats.sales["current_month"]!)"
            secondStatLabel.text = "Last Month: \(cellStats.sales["last_month"]!)"
            thirdStatLabel.text = "Total: \(cellStats.sales["totals"]!)"
        }
        
        // Earnings
        if heading == "Earnings Today" {
            stat = Site.currencyFormat(cellStats.earnings["today"] as! NSNumber)
            
            _earningsData = data.map({ Item -> Double in
                return Item as! Double
            })
            type = .earnings
            
            firstStatLabel.text = "Current Month: \(Site.currencyFormat(cellStats.earnings["current_month"] as! NSNumber))"
            secondStatLabel.text = "Last Month: \(Site.currencyFormat(cellStats.earnings["last_month"] as! NSNumber))"
            thirdStatLabel.text = "Total: \(Site.currencyFormat(cellStats.earnings["totals"] as! NSNumber))"
        }
    }
    
    func configureSmallStaticCell(_ heading: String, cellStat: String?) {
        title = heading
        
        guard let cellStat_ = cellStat else {
            return
        }
        
        stat = Site.currencyFormat((cellStat_ as NSString).doubleValue)
        
        // Store Commissions
        if heading == "Store Commissions" {
            type = .storeCommissions
        }
    }
    
    func configureStaticCell(_ heading: String, data: NSDictionary?) {
        title = heading
        
        // Commissions
        if heading == "Commissions" {
            type = .commissions
            
            guard let data_ = data else {
                return
            }
            
            let unpaid = (data_["unpaid"] as? NSString)?.doubleValue
            let paid = (data_["paid"] as? NSString)?.doubleValue
            let revoked = (data_["revoked"] as? NSString)?.doubleValue
            
            
            stat = Site.currencyFormat(unpaid!)
            
            firstStatLabel.text = NSLocalizedString("Unpaid:", comment: "") +  " " + "\(Site.currencyFormat(unpaid!))"
            secondStatLabel.text = NSLocalizedString("Paid:", comment: "") + " " + "\(Site.currencyFormat(paid!))"
            thirdStatLabel.text = NSLocalizedString("Revoked:", comment: "") + " " + "\(Site.currencyFormat(revoked!))"
        }
    }
    
    // MARK: BEMSimpleLineGraph
    
    func numberOfPoints(inLineGraph graph: BEMSimpleLineGraphView) -> Int {
        switch type {
            case .sales:
                return _salesData!.count
            case .earnings:
                return _earningsData!.count
            default:
                return 0
        }
    }
    
    func lineGraph(_ graph: BEMSimpleLineGraphView, valueForPointAt index: Int) -> CGFloat {
        switch type {
            case .sales:
                return CGFloat(_salesData![index])
            case .earnings:
                return CGFloat(_earningsData![index])
            default:
                return 0
        }
    }
    
    func numberOfGapsBetweenLabels(onLineGraph graph: BEMSimpleLineGraphView) -> Int {
        return 2
    }
    
    func lineGraph(_ graph: BEMSimpleLineGraphView, labelOnXAxisFor index: Int) -> String {
        return _dates![index] as String
    }
    
}
