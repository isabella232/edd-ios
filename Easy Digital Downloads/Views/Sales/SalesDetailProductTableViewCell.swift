//
//  SalesDetailProductTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 22/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import AlamofireImage

class SalesDetailProductTableViewCell: UITableViewCell {

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
    let quantityLabel: UILabel = UILabel(frame: CGRectZero)
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
        
        quantityLabel.textColor = .EDDBlackColor()
        quantityLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        
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
        containerStackView.addArrangedSubview(quantityLabel)
        containerStackView.addArrangedSubview(pricingLabel)
        
        contentView.addSubview(containerStackView)
        
        disclosureImageView.translatesAutoresizingMaskIntoConstraints = false
        disclosureImageView.sizeToFit()
        contentView.addSubview(disclosureImageView)
        
        layoutConstraints.append(NSLayoutConstraint(item: disclosureImageView, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .Trailing, multiplier: CGFloat(1), constant: -15))
        layoutConstraints.append(NSLayoutConstraint(item: disclosureImageView, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: CGFloat(1), constant: CGFloat(0)))
        layoutConstraints.append(containerStackView.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 15))
        layoutConstraints.append(containerStackView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor, constant: -15))
        layoutConstraints.append(containerStackView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 15))
        layoutConstraints.append(containerStackView.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor, constant: -15))
        
        NSLayoutConstraint.activateConstraints(layoutConstraints)
    }

    func configure(object: AnyObject) {
        titleLabel.text = object["name"] as? String
        
        let quantity = object["quantity"] as! NSNumber
        
        quantityLabel.text = NSLocalizedString("Quantity", comment: "") + ": \(quantity)"
        
        let priceName = object["price_name"] as? String
        
        if priceName?.characters.count == 0 {
            if let price = object["price"] as? NSNumber {
                pricingLabel.text = Site.currencyFormat(price)
            }
        } else {
            if let price = object["price"] as? Double {
                pricingLabel.text = priceName! + " - " + Site.currencyFormat(NSNumber(double: price))
            }
        }
    }

    
}
