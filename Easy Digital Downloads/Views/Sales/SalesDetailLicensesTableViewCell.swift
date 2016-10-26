//
//  SalesDetailLicensesTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 25/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import SwiftyJSON

class SalesDetailLicensesTableViewCell: UITableViewCell {

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
    
    private let nameLabel: UILabel = UILabel(frame: CGRectZero)
    private let statusLabel: UILabel = UILabel(frame: CGRectZero)
    private let keyLabel: UILabel = UILabel(frame: CGRectZero)

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        nameLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        nameLabel.textColor = .EDDBlueColor()
        nameLabel.lineBreakMode = .ByWordWrapping
        nameLabel.numberOfLines = 0
        
        keyLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        keyLabel.textColor = .EDDBlackColor()
        statusLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        statusLabel.textColor = .EDDBlackColor()
        
        selectionStyle = .None
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func layout() {
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(keyLabel)
        stackView.addArrangedSubview(statusLabel)

        containerView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMarginsRelativeArrangement = true
        stackView.alignment = .Top
        
        contentView.addSubview(containerView)

        var constraints = [NSLayoutConstraint]()
        constraints.append(nameLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 0.9))
        constraints.append(keyLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(statusLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(containerView.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 0))
        constraints.append(containerView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor, constant: 0))
        constraints.append(containerView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 0))
        constraints.append(containerView.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor, constant: 0))
        constraints.append(stackView.topAnchor.constraintEqualToAnchor(containerView.topAnchor, constant: 15))
        constraints.append(stackView.bottomAnchor.constraintEqualToAnchor(containerView.bottomAnchor, constant: -15))
        constraints.append(stackView.leadingAnchor.constraintEqualToAnchor(containerView.leadingAnchor, constant: 15))
        constraints.append(stackView.trailingAnchor.constraintEqualToAnchor(containerView.trailingAnchor, constant: 15))
        
        NSLayoutConstraint.activateConstraints(constraints)
    }
    
    func configure(license: JSON) {
        let name = license["name"].stringValue
        let status = license["status"].stringValue
        let key = license["key"].stringValue
        nameLabel.text = name
        statusLabel.text = status.capitalizedString
        keyLabel.text = key
        
        nameLabel.sizeToFit()
        
        layout()
    }
    
}
