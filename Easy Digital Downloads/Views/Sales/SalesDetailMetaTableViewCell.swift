//
//  SalesDetailMetaTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 22/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

class SalesDetailMetaTableViewCell: UITableViewCell {

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
        view.layer.masksToBounds = false
        return view
    }()
    
    private let titleLabel: UILabel = UILabel(frame: CGRectZero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.textColor = .EDDBlackColor()
        titleLabel.font = UIFont.systemFontOfSize(20, weight: UIFontWeightMedium)
        titleLabel.textAlignment = .Center
        
        selectionStyle = .None
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(sale: Sale) {
        let chargedText: String = NSLocalizedString("payment", comment: "")
        titleLabel.text = "\(Site.currencyFormat(sale.total)) \(chargedText)"
        
        layout()
    }
    
    func layout() {
        stackView.addArrangedSubview(titleLabel)

        containerView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMarginsRelativeArrangement = true
        stackView.alignment = .Top
        
        contentView.addSubview(containerView)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(titleLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(containerView.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 0))
        constraints.append(containerView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor, constant: 0))
        constraints.append(containerView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 0))
        constraints.append(containerView.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor, constant: 0))
        constraints.append(stackView.topAnchor.constraintEqualToAnchor(containerView.topAnchor, constant: 15))
        constraints.append(stackView.bottomAnchor.constraintEqualToAnchor(containerView.bottomAnchor, constant: -15))
        constraints.append(stackView.leadingAnchor.constraintEqualToAnchor(containerView.leadingAnchor, constant: 0))
        constraints.append(stackView.trailingAnchor.constraintEqualToAnchor(containerView.trailingAnchor, constant: 0))
        
        NSLayoutConstraint.activateConstraints(constraints)
    }

}
