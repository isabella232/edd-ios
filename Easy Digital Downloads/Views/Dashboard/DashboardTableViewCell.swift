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
}

class DashboardTableViewCell: UITableViewCell {
    var hasSetupConstraints = false
    var data: NSArray?
    
    let type: DashboardCell = .Sales
    
    lazy var stackView : UIStackView! = {
        let stack = UIStackView()
        stack.axis = .Vertical
        stack.distribution = .FillProportionally
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
        
        topStackView.addArrangedSubview(titleLabel)
        topStackView.addArrangedSubview(statLabel)
        
        stackView.addArrangedSubview(topStackView)
        
        containerView.addSubview(stackView)
        contentView.addSubview(containerView)
        
        topStackView.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor).active = true
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMarginsRelativeArrangement = true
        stackView.alignment = .Top
        
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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        
    }
    
    func configure(cellData: NSDictionary, stats: Stats?, graphData: [JSON]?) {
        title = cellData["title"] as! String
        
        guard let cellStats = stats, cellGraphData = graphData else {
            return
        }
        
        NSLog("\(cellGraphData)")
        
        // Sales
        if cellData["type"] as! Int == 1 {
            stat = "\(cellStats.sales["today"]!)"
        }
        
        // Earnings
        if cellData["type"] as! Int == 2 {
            let currency = site.currency!
            
            let localeComponents = [NSLocaleCurrencyCode: currency]
            let localeIdentifier = NSLocale.localeIdentifierFromComponents(localeComponents)
            let locale = NSLocale(localeIdentifier: localeIdentifier)
            let currencySymbol = locale.objectForKey(NSLocaleCurrencySymbol) as! String
            
            stat = "\(currencySymbol)\(cellStats.earnings["today"]!)"
        }
    }
    
}
