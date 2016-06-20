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
    case Sales = 1
    case Earnings = 2
    case Commissions = 3
    case Reviews = 4
    case None = 5
}

class DashboardTableViewCell: UITableViewCell, BEMSimpleLineGraphDelegate, BEMSimpleLineGraphDataSource {
    var hasSetupConstraints = false
    var data: NSArray?
    
    private var type: DashboardCell = .None
    
    lazy var stackView : UIStackView! = {
        let stack = UIStackView()
        stack.axis = .Vertical
        stack.distribution = .Fill
        stack.alignment = .Fill
        stack.spacing = 3.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Vertical)
        return stack
    }()
    
    lazy var topStackView : UIStackView! = {
        let stack = UIStackView()
        stack.alignment = .Center
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Horizontal)
        return stack
    }()
    
    lazy var middleStackView : UIStackView! = {
        let stack = UIStackView()
        stack.alignment = .Fill
        stack.distribution = .Fill
        stack.spacing = 3.0
        stack.axis = .Vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Vertical)
        return stack
    }()
    
    lazy var containerView: UIView! = {
        let view = UIView()
        view.backgroundColor = .EDDBlueColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = false
        view.layer.shadowOffset = CGSizeZero
        view.layer.shadowRadius = 3
        view.layer.shadowOpacity = 0.4
        view.layer.shadowColor = UIColor.blackColor().CGColor
        return view
    }()
    
    private var _title: String = ""
    private var _stat: String = ""
    private var _salesData: Array<Int>?
    private var _earningsData: Array<Double>?
    private var _dates: Array<String>?
    
    private let site: Site = Site.defaultSite()
    
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
    
    let titleLabel = UILabel(frame: CGRectZero)
    let statLabel = UILabel(frame: CGRectZero)
    let firstStatLabel = UILabel(frame: CGRectZero)
    let secondStatLabel = UILabel(frame: CGRectZero)
    let thirdStatLabel = UILabel(frame: CGRectZero)
    
    private var graph: BEMSimpleLineGraphView?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
        layer.opaque = true
        opaque = true
        
        backgroundColor = .clearColor()
        contentView.backgroundColor = .clearColor()

        titleLabel.textColor = .whiteColor()
        titleLabel.font = UIFont.systemFontOfSize(20, weight: UIFontWeightLight)
        titleLabel.text = data?.objectAtIndex(1) as? String
        
        statLabel.textColor = .whiteColor()
        statLabel.font = UIFont.systemFontOfSize(20, weight: UIFontWeightLight)
        
        firstStatLabel.textColor = .whiteColor()
        firstStatLabel.font = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
        firstStatLabel.text = "Current Month:"
        
        secondStatLabel.textColor = .whiteColor()
        secondStatLabel.font = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
        secondStatLabel.text = "Last Month:"
        
        thirdStatLabel.textColor = .whiteColor()
        thirdStatLabel.font = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
        thirdStatLabel.text = "Total:"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.type = .None
        
        self.graph?.removeFromSuperview()
    }
    
    func layout() {
        topStackView.addArrangedSubview(titleLabel)
        topStackView.addArrangedSubview(statLabel)
        
        middleStackView.addArrangedSubview(firstStatLabel)
        middleStackView.addArrangedSubview(secondStatLabel)
        middleStackView.addArrangedSubview(thirdStatLabel)
        
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
        graph.animationGraphStyle = .None
        graph.colorBackgroundXaxis = UIColor.clearColor()
        graph.colorBackgroundYaxis = UIColor.clearColor()
        graph.colorTop = UIColor.clearColor()
        graph.colorBottom = UIColor.clearColor()
        graph.backgroundColor = UIColor.clearColor()
        graph.tintColor = UIColor.clearColor()
        graph.colorYaxisLabel = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.5)
        graph.colorXaxisLabel = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.5)
        graph.alwaysDisplayDots = true
        graph.enablePopUpReport = true
        graph.enableTouchReport = true
        graph.translatesAutoresizingMaskIntoConstraints = false
        self.graph = graph
        middleStackView.addArrangedSubview(graph)
        graph.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor).active = true
        graph.heightAnchor.constraintEqualToConstant(115).active = true

        containerView.addSubview(stackView)
        
        topStackView.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor).active = true
        middleStackView.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor).active = true

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMarginsRelativeArrangement = true
        stackView.alignment = .Top
        
        contentView.addSubview(containerView)

        var constraints = [NSLayoutConstraint]()
        constraints.append(containerView.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 10))
        constraints.append(containerView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor, constant: -10))
        constraints.append(containerView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 15))
        constraints.append(containerView.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor, constant: -15))
        constraints.append(stackView.topAnchor.constraintEqualToAnchor(containerView.topAnchor, constant: 10))
        constraints.append(stackView.bottomAnchor.constraintEqualToAnchor(containerView.bottomAnchor, constant: -10))
        constraints.append(stackView.leadingAnchor.constraintEqualToAnchor(containerView.leadingAnchor, constant: 10))
        constraints.append(stackView.trailingAnchor.constraintEqualToAnchor(containerView.trailingAnchor, constant: -10))

        NSLayoutConstraint.activateConstraints(constraints)
    }
    
    func configure<T>(cellData: NSDictionary, stats: Stats?, data: Array<T>, dates: Array<String>) {
        title = cellData["title"] as! String
        
        guard let cellStats = stats else {
            return
        }
        
        _dates = dates
        
        // Sales
        if cellData["type"] as! Int == 1 {
            stat = "\(cellStats.sales["today"]!)"
            _salesData = data.map({ Item -> Int in
                return Item as! Int
            })
            type = .Sales
            
            firstStatLabel.text = "Current Month: \(cellStats.sales["current_month"]!)"
            secondStatLabel.text = "Last Month: \(cellStats.sales["last_month"]!)"
            thirdStatLabel.text = "Total: \(cellStats.sales["totals"]!)"
        }
        
        // Earnings
        if cellData["type"] as! Int == 2 {
            let currency = site.currency!
            
            let localeComponents = [NSLocaleCurrencyCode: currency]
            let localeIdentifier = NSLocale.localeIdentifierFromComponents(localeComponents)
            let locale = NSLocale(localeIdentifier: localeIdentifier)
            let currencySymbol = locale.objectForKey(NSLocaleCurrencySymbol) as! String
            
            stat = "\(currencySymbol)\(cellStats.earnings["today"]!)"
            _earningsData = data.map({ Item -> Double in
                return Item as! Double
            })
            type = .Earnings
            
            let formatter = NSNumberFormatter()
            formatter.numberStyle = .CurrencyStyle
            
            firstStatLabel.text = "Current Month: \(formatter.stringFromNumber(cellStats.earnings["current_month"] as! NSNumber)!)"
            secondStatLabel.text = "Last Month: \(formatter.stringFromNumber(cellStats.earnings["last_month"] as! NSNumber)!)"
            thirdStatLabel.text = "Total: \(formatter.stringFromNumber(cellStats.earnings["totals"] as! NSNumber)!)"
        }
    }
    
    func configureStaticCell(cellData: NSDictionary, data: NSDictionary) {
        title = cellData["title"] as! String
        
        // Commissions
        if cellData["type"] as! Int == 3 {
            type = .Commissions
        }
    }
    
    // MARK: BEMSimpleLineGraph
    
    func numberOfPointsInLineGraph(graph: BEMSimpleLineGraphView) -> Int {
        switch type {
            case .Sales:
                return _salesData!.count
            case .Earnings:
                return _earningsData!.count
            default:
                return 0
        }
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, valueForPointAtIndex index: Int) -> CGFloat {
        switch type {
            case .Sales:
                return CGFloat(_salesData![index])
            case .Earnings:
                return CGFloat(_earningsData![index])
            default:
                return 0
        }
    }
    
    func numberOfGapsBetweenLabelsOnLineGraph(graph: BEMSimpleLineGraphView) -> Int {
        return 2
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, labelOnXAxisForIndex index: Int) -> String {
        return _dates![index] as String
    }
    
}
