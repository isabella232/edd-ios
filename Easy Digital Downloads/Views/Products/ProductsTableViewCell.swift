//
//  ProductsTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 01/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import AlamofireImage

class ProductsTableViewCell: UITableViewCell {
    
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
    var thumbnailImageView: UIImageView = UIImageView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
        layer.opaque = true
        opaque = true
        
        backgroundColor = .clearColor()
        contentView.backgroundColor = .clearColor()
        
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
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: disclosureImageView, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .Trailing, multiplier: CGFloat(1), constant: -15))
        constraints.append(NSLayoutConstraint(item: disclosureImageView, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: CGFloat(1), constant: CGFloat(0)))
        constraints.append(containerStackView.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 15))
        constraints.append(containerStackView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor, constant: -15))
        constraints.append(containerStackView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 15))
        constraints.append(containerStackView.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor, constant: -15))
        
        NSLayoutConstraint.activateConstraints(constraints)
    }
    
}

extension ProductsTableViewCell: ConfigurableCell {
    
    func configureForObject(object: Product) {
        titleLabel.text = object.title
        
        let pricing: [String: AnyObject] = NSKeyedUnarchiver.unarchiveObjectWithData(object.pricing) as! [String: AnyObject]
        
        if object.hasVariablePricing == true {
            var sortedArray = [Double]()
            for (_, value) in pricing {
                let price = Double(value as! String)
                sortedArray.append(price!)
            }
            
            sortedArray.sortInPlace {
                return $0 < $1
            }
            
            pricingLabel.text = "\(Site.currencyFormat(NSNumber(double: sortedArray[0]))) - \(Site.currencyFormat(NSNumber(double: sortedArray[sortedArray.count - 1])))"
        } else {
            let doubleObject = Double(pricing["amount"] as! String)
            pricingLabel.text = "\(Site.currencyFormat(NSNumber(double: doubleObject!)))"
        }
    }
    
}
