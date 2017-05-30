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

    fileprivate var hasSetupConstraints = false
    
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
    
    let titleLabel: UILabel = UILabel(frame: CGRect.zero)
    let quantityLabel: UILabel = UILabel(frame: CGRect.zero)
    let pricingLabel: UILabel = UILabel(frame: CGRect.zero)
    let disclosureImageView: UIImageView = UIImageView(image: UIImage(named: "DisclosureIndicator"))
    var layoutConstraints = [NSLayoutConstraint]()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.isOpaque = true
        isOpaque = true
        
        backgroundColor = .white
        contentView.backgroundColor = .white
        
        titleLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        titleLabel.textColor = .EDDBlueColor()
        
        quantityLabel.textColor = .EDDBlackColor()
        quantityLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        
        pricingLabel.textColor = .EDDBlackColor()
        pricingLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Private
    
    fileprivate func layout() {
        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(quantityLabel)
        containerStackView.addArrangedSubview(pricingLabel)
        
        contentView.addSubview(containerStackView)
        
        disclosureImageView.translatesAutoresizingMaskIntoConstraints = false
        disclosureImageView.sizeToFit()
        contentView.addSubview(disclosureImageView)
        
        layoutConstraints.append(NSLayoutConstraint(item: disclosureImageView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: CGFloat(1), constant: -15))
        layoutConstraints.append(NSLayoutConstraint(item: disclosureImageView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: CGFloat(1), constant: CGFloat(0)))
        layoutConstraints.append(containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15))
        layoutConstraints.append(containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15))
        layoutConstraints.append(containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15))
        layoutConstraints.append(containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15))
        
        NSLayoutConstraint.activate(layoutConstraints)
    }

    func configure(_ object: JSON) {
        titleLabel.text = object["name"].stringValue
        
        let quantity = object["quantity"].intValue
        
        quantityLabel.text = NSLocalizedString("Quantity", comment: "") + ": \(quantity)"
        
        let priceName = object["price_name"].stringValue
        
        if priceName.characters.count == 0 {
            if let price = object["price"].double {
                pricingLabel.text = Site.currencyFormat(price)
            }
        } else {
            if let price = object["price"].double {
                pricingLabel.text = priceName + " - " + Site.currencyFormat(NSNumber(double: price))
            }
        }
    }

    
}
