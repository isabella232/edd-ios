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
        view.layer.masksToBounds = false
        return view
    }()
    
    fileprivate let nameLabel: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let statusLabel: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let keyLabel: UILabel = UILabel(frame: CGRect.zero)

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        nameLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        nameLabel.textColor = .EDDBlueColor()
        nameLabel.lineBreakMode = .byWordWrapping
        nameLabel.numberOfLines = 0
        
        keyLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        keyLabel.textColor = .EDDBlackColor()
        statusLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        statusLabel.textColor = .EDDBlackColor()
        
        selectionStyle = .none
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
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.alignment = .top
        
        contentView.addSubview(containerView)

        var constraints = [NSLayoutConstraint]()
        constraints.append(nameLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.9))
        constraints.append(keyLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(statusLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0))
        constraints.append(containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0))
        constraints.append(containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0))
        constraints.append(containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0))
        constraints.append(stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15))
        constraints.append(stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15))
        constraints.append(stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15))
        constraints.append(stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 15))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func configure(_ license: JSON) {
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
