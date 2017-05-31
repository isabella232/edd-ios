//
//  CustomerStatsTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 20/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

private let sharedNumberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = Site.activeSite().currency!
    return formatter
}()

class CustomerStatsTableViewCell: UITableViewCell {

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
    
    lazy var containerView: UIView! = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate var customer: Customer?
    fileprivate let titleLabel = UILabel(frame: CGRect.zero)
    fileprivate let totalDownloadsLabel = UILabel(frame: CGRect.zero)
    fileprivate let totalPurchasesLabel = UILabel(frame: CGRect.zero)
    fileprivate let totalSpentLabel = UILabel(frame: CGRect.zero)

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        backgroundColor = .tableViewCellHighlightColor()
        
        titleLabel.textColor = .tableViewCellHeadingColor()
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight)
        titleLabel.textAlignment = .left
        titleLabel.text = NSLocalizedString("Stats", comment: "").localizedUppercase
        
        
        totalDownloadsLabel.textColor = .EDDBlackColor()
        totalDownloadsLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        
        totalSpentLabel.textColor = .EDDBlackColor()
        totalSpentLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        
        totalPurchasesLabel.textColor = .EDDBlackColor()
        totalPurchasesLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func layout() {
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(totalPurchasesLabel)
        stackView.addArrangedSubview(totalSpentLabel)
        stackView.addArrangedSubview(totalDownloadsLabel)
        
        containerView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.alignment = .top
        
        contentView.addSubview(containerView)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(titleLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(titleLabel.bottomAnchor.constraint(equalTo: totalPurchasesLabel.topAnchor, constant: -10))
        constraints.append(totalDownloadsLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(totalSpentLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(totalPurchasesLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10))
        constraints.append(containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10))
        constraints.append(containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10))
        constraints.append(containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10))
        constraints.append(stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10))
        constraints.append(stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10))
        constraints.append(stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10))
        constraints.append(stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func configure(_ customer: Customer) {
        self.customer = customer
        
        totalDownloadsLabel.text = NSLocalizedString("Total Downloads: \(customer.totalDownloads)", comment: "")
        totalSpentLabel.text = NSLocalizedString("Total Spent: \(sharedNumberFormatter.string(from: NSNumber(customer.totalSpent))!)", comment: "")
        totalPurchasesLabel.text = NSLocalizedString("Total Purchases: \(customer.totalPurchases)", comment: "")
        
        layout()
    }
    
}
