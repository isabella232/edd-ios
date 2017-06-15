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
    
    fileprivate let licensingDisabledLabel = UILabel(frame: CGRect.zero)
    fileprivate let licensingVersionLabel = UILabel(frame: CGRect.zero)
    fileprivate let licensingExpiryLabel = UILabel(frame: CGRect.zero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        licensingDisabledLabel.lineBreakMode = .byWordWrapping
        licensingDisabledLabel.numberOfLines = 0
        licensingDisabledLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        licensingDisabledLabel.textColor = .EDDBlackColor()
        
        licensingVersionLabel.textColor = .EDDBlackColor()
        licensingVersionLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        
        licensingExpiryLabel.textColor = .EDDBlackColor()
        licensingExpiryLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(_ licensing: [String: AnyObject]) {
        let enabled = Bool(NSNumber(value: licensing["enabled"]!.int64Value))
    
        if !enabled {
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
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.alignment = .top
        
        contentView.addSubview(containerView)
        
        var constraints = [NSLayoutConstraint]()
        
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

}
