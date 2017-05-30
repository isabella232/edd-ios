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
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 3.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        return stack
    }()

    let label = UILabel(frame: CGRect.zero)
    let textField = UITextField(frame: CGRect.zero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.isOpaque = true
        isOpaque = true
        
        backgroundColor = .white
        contentView.backgroundColor = .white
        
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        label.textColor = .EDDBlueColor()
        
        textField.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        textField.textColor = .EDDBlackColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func layout() {
        containerStackView.addArrangedSubview(label)
        containerStackView.addArrangedSubview(textField)
        
        contentView.addSubview(containerStackView)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15))
        constraints.append(containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15))
        constraints.append(containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15))
        constraints.append(containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func configure(_ label: String, text: String) {
        self.label.text = label
        textField.text = text
    }
    
    func textFieldText() -> String {
        return textField.text!
    }
    
}
