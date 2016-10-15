//
//  SubscriptionsDetailHeadingTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 26/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

class SubscriptionsDetailHeadingTableViewCell: UITableViewCell {

    lazy var containerStackView  : UIStackView! = {
        let stack = UIStackView()
        stack.axis = .Vertical
        stack.distribution = .Fill
        stack.alignment = .Fill
        stack.spacing = 3.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Vertical)
        return stack
    }()
    
    private let headingLabel = UILabel(frame: CGRectZero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .None
        
        backgroundColor = .EDDGreyColor()
        
        headingLabel.textColor = .EDDBlackColor()
        headingLabel.font = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
        headingLabel.textAlignment = .Left
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func layout() {
        containerStackView .addArrangedSubview(headingLabel)
        
        containerStackView .translatesAutoresizingMaskIntoConstraints = false
        containerStackView .layoutMarginsRelativeArrangement = true
        containerStackView .alignment = .Top
        
        contentView.addSubview(containerStackView )
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(headingLabel.widthAnchor.constraintEqualToAnchor(containerStackView .widthAnchor, multiplier: 1.0))
        constraints.append(headingLabel.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor, constant: -10))
        constraints.append(containerStackView.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 15))
        constraints.append(containerStackView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor, constant: -15))
        constraints.append(containerStackView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 15))
        constraints.append(containerStackView.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor, constant: -15))
        
        NSLayoutConstraint.activateConstraints(constraints)
    }
    
    func configure(heading: String) {
        headingLabel.text = heading.uppercaseString
        
        layout()
    }


}
