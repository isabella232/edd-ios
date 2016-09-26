//
//  SubscriptionsDetailProductTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 26/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import SwiftyJSON

class SubscriptionsDetailProductTableViewCell: UITableViewCell {

    private var hasSetupConstraints = false
    
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
    
    let titleLabel: UILabel = UILabel(frame: CGRectZero)
    let pricingLabel: UILabel = UILabel(frame: CGRectZero)
    let disclosureImageView: UIImageView = UIImageView(image: UIImage(named: "DisclosureIndicator"))
    var layoutConstraints = [NSLayoutConstraint]()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
        layer.opaque = true
        opaque = true
        
        backgroundColor = .whiteColor()
        contentView.backgroundColor = .whiteColor()
        
        titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        titleLabel.textColor = .EDDBlueColor()
        
        pricingLabel.textColor = .EDDBlackColor()
        pricingLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Private
    
    private func layout() {
        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(pricingLabel)
        
        contentView.addSubview(containerStackView)
        
        disclosureImageView.translatesAutoresizingMaskIntoConstraints = false
        disclosureImageView.sizeToFit()
        contentView.addSubview(disclosureImageView)
        
        layoutConstraints.append(NSLayoutConstraint(item: disclosureImageView, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .Trailing, multiplier: CGFloat(1), constant: -15))
        layoutConstraints.append(NSLayoutConstraint(item: disclosureImageView, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: CGFloat(1), constant: CGFloat(0)))
        layoutConstraints.append(containerStackView.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 20))
        layoutConstraints.append(containerStackView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor, constant: -20))
        layoutConstraints.append(containerStackView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 20))
        layoutConstraints.append(containerStackView.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor, constant: -20))
        
        NSLayoutConstraint.activateConstraints(layoutConstraints)
    }
    
    func configure(AnyObj: JSON?) {
        guard let object = AnyObj else {
            return
        }
        
        let pricing = object["pricing"].dictionaryValue
        
        if pricing.count > 1 {
            var sortedArray = [Double]()
            for (_, value) in pricing {
                let price = Double(value.stringValue)
                sortedArray.append(price!)
            }
            
            sortedArray.sortInPlace {
                return $0 < $1
            }
            
            pricingLabel.text = "\(Site.currencyFormat(NSNumber(double: sortedArray[0]))) - \(Site.currencyFormat(NSNumber(double: sortedArray[sortedArray.count - 1])))"
        } else {
            let doubleObject = Double((pricing["amount"]?.stringValue)!)
            pricingLabel.text = "\(Site.currencyFormat(NSNumber(double: doubleObject!)))"
        }

        titleLabel.text = object["info"]["title"].stringValue
    }

}
