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
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 3.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        return stack
    }()
    
    fileprivate let headingLabel = UILabel(frame: CGRect.zero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        backgroundColor = .EDDGreyColor()
        
        headingLabel.textColor = .EDDBlackColor()
        headingLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight)
        headingLabel.textAlignment = .left
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func layout() {
        containerStackView .addArrangedSubview(headingLabel)
        
        containerStackView .translatesAutoresizingMaskIntoConstraints = false
        containerStackView .isLayoutMarginsRelativeArrangement = true
        containerStackView .alignment = .top
        
        contentView.addSubview(containerStackView )
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(headingLabel.widthAnchor.constraint(equalTo: containerStackView .widthAnchor, multiplier: 1.0))
        constraints.append(headingLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10))
        constraints.append(containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15))
        constraints.append(containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15))
        constraints.append(containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15))
        constraints.append(containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func configure(_ heading: String) {
        headingLabel.text = heading.uppercased()
        
        layout()
    }


}
