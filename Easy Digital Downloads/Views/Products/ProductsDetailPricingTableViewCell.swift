//
//  ProductsDetailPricingTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 25/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

class ProductsDetailPricingTableViewCell: UITableViewCell {

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
    
    fileprivate let hasVariablePricingLabel = UILabel(frame: CGRect.zero)
    fileprivate let pricingOptionsLabel = UILabel(frame: CGRect.zero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        hasVariablePricingLabel.textColor = .EDDBlackColor()
        hasVariablePricingLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        
        pricingOptionsLabel.lineBreakMode = .byWordWrapping
        pricingOptionsLabel.numberOfLines = 0
        pricingOptionsLabel.textColor = .EDDBlackColor()
        pricingOptionsLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(_ variablePricing: Bool, pricing: Data) {
        let pricingDict: [String: AnyObject] = NSKeyedUnarchiver.unarchiveObject(with: pricing) as! [String: AnyObject]
        
        var pricingText = ""

        for (key, value) in pricingDict {
            pricingText += key.capitalized + ": " + Site.currencyFormat(NSNumber(value: (value as! NSString).doubleValue)) + "\n"
        }
        
        pricingText = pricingText.substring(to: pricingText.characters.index(pricingText.endIndex, offsetBy: -2))
        
        hasVariablePricingLabel.text = NSLocalizedString("Variable Pricing: ", comment: "") + variablePricing.description.capitalized
        pricingOptionsLabel.text = pricingText
        
        layout()
    }
    
    func layout() {
        stackView.addArrangedSubview(hasVariablePricingLabel)
        stackView.addArrangedSubview(pricingOptionsLabel)
        
        containerView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.alignment = .top
        
        contentView.addSubview(containerView)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(hasVariablePricingLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(pricingOptionsLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
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
