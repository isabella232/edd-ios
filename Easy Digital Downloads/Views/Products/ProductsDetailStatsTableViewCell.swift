//
//  ProductsDetailStatsTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 25/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

class ProductsDetailStatsTableViewCell: UITableViewCell {

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
    
    lazy var containerView: UIView! = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let totalLabel = UILabel(frame: CGRectZero)
    private let totalStatsLabel = UILabel(frame: CGRectZero)
    private let monthlyAverageLabel = UILabel(frame: CGRectZero)
    private let monthlyAverageStatsLabel = UILabel(frame: CGRectZero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        totalLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        totalLabel.textColor = .EDDBlueColor()
        totalLabel.text = NSLocalizedString("Total", comment: "")
        monthlyAverageLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        monthlyAverageLabel.textColor = .EDDBlueColor()
        monthlyAverageLabel.text = NSLocalizedString("Monthly Average", comment: "")
        
        totalStatsLabel.lineBreakMode = .ByWordWrapping
        totalStatsLabel.numberOfLines = 0
        monthlyAverageStatsLabel.lineBreakMode = .ByWordWrapping
        monthlyAverageStatsLabel.numberOfLines = 0
        
        selectionStyle = .None
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(stats: NSData?) {
        let statsDict: [String: AnyObject] = NSKeyedUnarchiver.unarchiveObjectWithData(stats!) as! [String: AnyObject]
        
        let total = statsDict["total"]!
        let totalSales = total["sales"] as! String
        
        let monthly = statsDict["monthly_average"]!
        let monthlyAverageSales = (monthly["sales"]! as! NSNumber).stringValue
        let monthlyAverageEarnings = NSNumber(double: monthly["earnings"] as! Double)

        let totalStatsString = NSLocalizedString("Sales", comment: "") + ": \(totalSales)\n" + NSLocalizedString("Earnings", comment: "") + ": " + Site.currencyFormat((total["earnings"] as! NSString).doubleValue)
        totalStatsLabel.text = totalStatsString
        
        let monthlyAverageStatsString = NSLocalizedString("Sales", comment: "") + ": \(monthlyAverageSales)\n" + NSLocalizedString("Earnings", comment: "") + ": " + Site.currencyFormat(monthlyAverageEarnings)
        monthlyAverageStatsLabel.text = monthlyAverageStatsString
        
        totalStatsLabel.sizeToFit()
        monthlyAverageStatsLabel.sizeToFit()
        
        layout()
    }
    
    func layout() {
        stackView.addArrangedSubview(totalLabel)
        stackView.addArrangedSubview(totalStatsLabel)
        stackView.addArrangedSubview(monthlyAverageLabel)
        stackView.addArrangedSubview(monthlyAverageStatsLabel)
        
        containerView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMarginsRelativeArrangement = true
        stackView.alignment = .Top
        
        contentView.addSubview(containerView)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(totalLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(totalStatsLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(totalStatsLabel.bottomAnchor.constraintEqualToAnchor(monthlyAverageLabel.topAnchor, constant: -20))
        constraints.append(monthlyAverageLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(monthlyAverageStatsLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(containerView.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 10))
        constraints.append(containerView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor, constant: -10))
        constraints.append(containerView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 10))
        constraints.append(containerView.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor, constant: -10))
        constraints.append(stackView.topAnchor.constraintEqualToAnchor(containerView.topAnchor, constant: 10))
        constraints.append(stackView.bottomAnchor.constraintEqualToAnchor(containerView.bottomAnchor, constant: -10))
        constraints.append(stackView.leadingAnchor.constraintEqualToAnchor(containerView.leadingAnchor, constant: 10))
        constraints.append(stackView.trailingAnchor.constraintEqualToAnchor(containerView.trailingAnchor, constant: -10))
        
        NSLayoutConstraint.activateConstraints(constraints)
    }

}
