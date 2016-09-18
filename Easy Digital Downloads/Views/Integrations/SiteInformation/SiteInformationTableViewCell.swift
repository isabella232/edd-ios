//
//  SiteInformationTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 18/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

class SiteInformationTableViewCell: UITableViewCell {

    var hasSetupConstraints = false
    
    lazy var containerStackView: UIStackView! = {
        let stack = UIStackView()
        stack.axis = .Vertical
        stack.distribution = .Fill
        stack.alignment = .Fill
        stack.spacing = 3.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Vertical)
        return stack
    }()

    let label = UILabel(frame: CGRectZero)
    let textField = UITextField(frame: CGRectZero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
        layer.opaque = true
        opaque = true
        
        backgroundColor = .clearColor()
        contentView.backgroundColor = .clearColor()
        
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        label.textColor = .EDDBlueColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func layout() {
        containerStackView.addArrangedSubview(label)
        containerStackView.addArrangedSubview(textField)
        
        contentView.addSubview(containerStackView)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(containerStackView.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 15))
        constraints.append(containerStackView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor, constant: -15))
        constraints.append(containerStackView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 15))
        constraints.append(containerStackView.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor, constant: -15))
        
        NSLayoutConstraint.activateConstraints(constraints)
    }
    
    func configure(label: String, text: String) {
        self.label.text = label
        textField.text = text
    }
    
}
