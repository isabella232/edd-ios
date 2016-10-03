//
//  DiscountsTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 03/10/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

private let sharedDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    formatter.dateFormat = "EEE dd MMM yyyy HH:mm:ss"
    return formatter
}()


class DiscountsTableViewCell: UITableViewCell {

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
    
    let productNameLabel = UILabel(frame: CGRectZero)
    let codeLabel = UILabel(frame: CGRectZero)
    let statusLabel = CommissionsStatusLabel(frame: CGRectZero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
        layer.opaque = true
        opaque = true
        
        backgroundColor = .clearColor()
        contentView.backgroundColor = .clearColor()
        
        productNameLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        productNameLabel.textColor = .EDDBlueColor()
        
        codeLabel.textColor = .EDDBlackColor()
        codeLabel.font = UIFont(name: "Menlo-Regular", size: 13)
        
        statusLabel.font = UIFont.systemFontOfSize(13, weight: UIFontWeightMedium)
        statusLabel.textColor = .whiteColor()
        statusLabel.backgroundColor = .orangeColor()
        statusLabel.layer.cornerRadius = 2
        statusLabel.layer.borderWidth = 1
        statusLabel.layer.borderColor = UIColor.orangeColor().CGColor
        statusLabel.layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func layout() {
        containerStackView.addArrangedSubview(productNameLabel)
        containerStackView.addArrangedSubview(codeLabel)
        
        contentView.addSubview(containerStackView)
        
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.sizeToFit()
        contentView.addSubview(statusLabel)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: statusLabel, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .Trailing, multiplier: CGFloat(1), constant: -15))
        constraints.append(NSLayoutConstraint(item: statusLabel, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: CGFloat(1), constant: CGFloat(0)))
        constraints.append(containerStackView.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 15))
        constraints.append(containerStackView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor, constant: -15))
        constraints.append(containerStackView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 15))
        constraints.append(containerStackView.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor, constant: -15))
        
        NSLayoutConstraint.activateConstraints(constraints)
    }
    
    func configure(data: Discounts) {
        productNameLabel.text = data.name
        codeLabel.text = data.code
        
        if data.status == "active" {
            statusLabel.backgroundColor = .validColor()
            statusLabel.layer.borderColor = UIColor.validColor().CGColor
        }
        
        if data.status == "inactive" {
            statusLabel.backgroundColor = .errorColor()
            statusLabel.layer.borderColor = UIColor.errorColor().CGColor
        }
        
        statusLabel.text = data.status.uppercaseString
        statusLabel.sizeToFit()
        
        layout()
    }

}
