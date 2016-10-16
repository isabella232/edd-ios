//
//  FileDownloadLogsProductTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 28/08/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import AlamofireImage

class FileDownloadLogsProductTableViewCell: UITableViewCell {

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
    private var thumbnailImageView: UIImageView = UIImageView(frame: CGRectZero)
    var layoutConstraints = [NSLayoutConstraint]()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        thumbnailImageView = {
            let imageView = UIImageView(frame: CGRectZero)
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .ScaleAspectFit
            imageView.clipsToBounds = true
            
            return imageView
        }()
        
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        thumbnailImageView.af_cancelImageRequest()
        thumbnailImageView.layer.removeAllAnimations()
        thumbnailImageView.image = nil
        
        layoutConstraints.removeAll()
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
    }
    
    func configureForObject(product: Product?) {
        guard let object = product else {
            return
        }
        
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
        
        if object.thumbnail?.characters.count > 5 && object.thumbnail != "false" {
            contentView.addSubview(thumbnailImageView)
            
            layoutConstraints.append(thumbnailImageView.widthAnchor.constraintEqualToConstant(40))
            layoutConstraints.append(thumbnailImageView.heightAnchor.constraintEqualToConstant(40))
            layoutConstraints.append(thumbnailImageView.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 15))
            layoutConstraints.append(thumbnailImageView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 15))
            layoutConstraints.append(containerStackView.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 15))
            layoutConstraints.append(containerStackView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor, constant: -15))
            layoutConstraints.append(containerStackView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 65))
            layoutConstraints.append(containerStackView.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor, constant: -15))
            
            let url = NSURL(string: object.thumbnail!)
            thumbnailImageView.af_setImageWithURL(url!, placeholderImage: nil, filter: AspectScaledToFillSizeWithRoundedCornersFilter(size: CGSizeMake(60, 60), radius: 30), progress: nil, progressQueue: dispatch_get_main_queue(), imageTransition: .CrossDissolve(0.2), runImageTransitionIfCached: true, completion: nil)
        } else {
            thumbnailImageView.removeFromSuperview()
            
            layoutConstraints.append(containerStackView.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 15))
            layoutConstraints.append(containerStackView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor, constant: -15))
            layoutConstraints.append(containerStackView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 15))
            layoutConstraints.append(containerStackView.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor, constant: -15))
        }
        
        NSLayoutConstraint.activateConstraints(layoutConstraints)
    }

}
