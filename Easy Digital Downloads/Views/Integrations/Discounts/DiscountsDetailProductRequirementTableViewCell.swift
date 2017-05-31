//
//  DiscountsDetailProductRequirementTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 18/10/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import AlamofireImage
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class DiscountsDetailProductRequirementTableViewCell: UITableViewCell {

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
    let pricingLabel: UILabel = UILabel(frame: CGRect.zero)
    let disclosureImageView: UIImageView = UIImageView(image: UIImage(named: "DisclosureIndicator"))
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    fileprivate var thumbnailImageView: UIImageView = UIImageView(frame: CGRect.zero)
    var layoutConstraints = [NSLayoutConstraint]()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        thumbnailImageView = {
            let imageView = UIImageView(frame: CGRect.zero)
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            
            return imageView
        }()
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.isOpaque = true
        isOpaque = true
        
        backgroundColor = .white
        contentView.backgroundColor = .white
        
        titleLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        titleLabel.textColor = .EDDBlueColor()
        
        pricingLabel.textColor = .EDDBlackColor()
        pricingLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        
        activityIndicator.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        activityIndicator.center = contentView.center
        
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        thumbnailImageView.af_cancelImageRequest()
        thumbnailImageView.layer.removeAllAnimations()
        thumbnailImageView.image = nil
        
        layoutConstraints.removeAll()
    }
    
    // MARK: Private
    
    fileprivate func layout() {
        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(pricingLabel)
        
        contentView.addSubview(containerStackView)
        
        disclosureImageView.translatesAutoresizingMaskIntoConstraints = false
        disclosureImageView.sizeToFit()
        contentView.addSubview(disclosureImageView)
        
        layoutConstraints.append(NSLayoutConstraint(item: disclosureImageView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: CGFloat(1), constant: -15))
        layoutConstraints.append(NSLayoutConstraint(item: disclosureImageView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: CGFloat(1), constant: CGFloat(0)))
    }
    
    func configure(_ product: Product?) {
        guard let object = product else {
            activityIndicator.startAnimating()
            contentView.addSubview(activityIndicator)
            return
        }
        
        titleLabel.text = object.title
        
        let pricing: [String: AnyObject] = NSKeyedUnarchiver.unarchiveObject(with: object.pricing as Data) as! [String: AnyObject]
        
        if object.hasVariablePricing == true {
            var sortedArray = [Double]()
            for (_, value) in pricing {
                let price = Double(value as! String)
                sortedArray.append(price!)
            }
            
            sortedArray.sort {
                return $0 < $1
            }
            
            pricingLabel.text = "\(Site.currencyFormat(NSNumber(value: sortedArray[0] as Double))) - \(Site.currencyFormat(NSNumber(value: sortedArray[sortedArray.count - 1] as Double)))"
        } else {
            let doubleObject = Double(pricing["amount"] as! String)
            pricingLabel.text = "\(Site.currencyFormat(NSNumber(value: doubleObject! as Double)))"
        }
        
        if object.thumbnail?.characters.count > 5 && object.thumbnail != "false" {
            contentView.addSubview(thumbnailImageView)
            
            layoutConstraints.append(thumbnailImageView.widthAnchor.constraint(equalToConstant: 40))
            layoutConstraints.append(thumbnailImageView.heightAnchor.constraint(equalToConstant: 40))
            layoutConstraints.append(thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15))
            layoutConstraints.append(thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15))
            layoutConstraints.append(containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15))
            layoutConstraints.append(containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15))
            layoutConstraints.append(containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 65))
            layoutConstraints.append(containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15))
            
            let url = URL(string: object.thumbnail!)
            thumbnailImageView.af_setImage(withURL: url!, placeholderImage: nil, filter: AspectScaledToFillSizeWithRoundedCornersFilter(size: CGSize(width: 60, height: 60), radius: 30), progress: nil, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: true, completion: nil)
        } else {
            thumbnailImageView.removeFromSuperview()
            
            layoutConstraints.append(containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15))
            layoutConstraints.append(containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15))
            layoutConstraints.append(containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15))
            layoutConstraints.append(containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15))
        }
        
        NSLayoutConstraint.activate(layoutConstraints)
    }

}
