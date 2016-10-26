//
//  ProductsDetailLicensingTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 25/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

class ProductsDetailLicensingTableViewCell: UITableViewCell {

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
    
    private let licensingDisabledLabel = UILabel(frame: CGRectZero)
    private let licensingVersionLabel = UILabel(frame: CGRectZero)
    private let licensingExpiryLabel = UILabel(frame: CGRectZero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        licensingDisabledLabel.lineBreakMode = .ByWordWrapping
        licensingDisabledLabel.numberOfLines = 0
        licensingDisabledLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        licensingDisabledLabel.textColor = .EDDBlackColor()
        
        licensingVersionLabel.textColor = .EDDBlackColor()
        licensingVersionLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        
        licensingExpiryLabel.textColor = .EDDBlackColor()
        licensingExpiryLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        
        selectionStyle = .None
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(licensing: [String: AnyObject]) {
        let enabled = (licensing["enabled"] as! NSNumber).boolValue
        if enabled == false {
            licensingDisabledLabel.text = NSLocalizedString("Software Licensing has not been enabled for this product.", comment: "")
            stackView.addArrangedSubview(licensingDisabledLabel)
        } else {
            licensingVersionLabel.text = NSLocalizedString("Current Version: ", comment: "") + "\(licensing["version"]!)"
            licensingExpiryLabel.text = NSLocalizedString("License Validity: ", comment: "") + "\(licensing["exp_length"]!) \(licensing["exp_unit"]!)"
            stackView.addArrangedSubview(licensingVersionLabel)
            stackView.addArrangedSubview(licensingExpiryLabel)
        }
        
        containerView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMarginsRelativeArrangement = true
        stackView.alignment = .Top
        
        contentView.addSubview(containerView)
        
        var constraints = [NSLayoutConstraint]()
        
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
