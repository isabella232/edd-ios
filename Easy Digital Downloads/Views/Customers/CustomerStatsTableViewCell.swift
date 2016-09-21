//
//  CustomerStatsTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 20/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

private let sharedNumberFormatter: NSNumberFormatter = {
    let formatter = NSNumberFormatter()
    formatter.numberStyle = .CurrencyStyle
    formatter.currencyCode = Site.activeSite().currency!
    return formatter
}()

class CustomerStatsTableViewCell: UITableViewCell {

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
    
    private var customer: Customer?
    private let titleLabel = UILabel(frame: CGRectZero)
    private let totalDownloadsLabel = UILabel(frame: CGRectZero)
    private let totalPurchasesLabel = UILabel(frame: CGRectZero)
    private let totalSpentLabel = UILabel(frame: CGRectZero)

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .None
        
        backgroundColor = .tableViewCellHighlightColor()
        
        titleLabel.textColor = .tableViewCellHeadingColor()
        titleLabel.font = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
        titleLabel.textAlignment = .Left
        titleLabel.text = NSLocalizedString("Stats", comment: "").localizedUppercaseString
        
        
        totalDownloadsLabel.textColor = .EDDBlackColor()
        totalDownloadsLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        
        totalSpentLabel.textColor = .EDDBlackColor()
        totalSpentLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        
        totalPurchasesLabel.textColor = .EDDBlackColor()
        totalPurchasesLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func layout() {
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(totalPurchasesLabel)
        stackView.addArrangedSubview(totalSpentLabel)
        stackView.addArrangedSubview(totalDownloadsLabel)
        
        containerView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMarginsRelativeArrangement = true
        stackView.alignment = .Top
        
        contentView.addSubview(containerView)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(titleLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(titleLabel.bottomAnchor.constraintEqualToAnchor(totalPurchasesLabel.topAnchor, constant: -10))
        constraints.append(totalDownloadsLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(totalSpentLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(totalPurchasesLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
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
    
    func configure(customer: Customer) {
        self.customer = customer
        
        totalDownloadsLabel.text = NSLocalizedString("Total Downloads: \(customer.totalDownloads)", comment: "")
        totalSpentLabel.text = NSLocalizedString("Total Spent: \(sharedNumberFormatter.stringFromNumber(customer.totalSpent)!)", comment: "")
        totalPurchasesLabel.text = NSLocalizedString("Total Purchases: \(customer.totalPurchases)", comment: "")
        
        layout()
    }
    
}
