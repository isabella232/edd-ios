//
//  StoreCommissionsTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 29/09/2016.
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

class StoreCommissionsTableViewCell: UITableViewCell {
    
    var hasSetupConstraints = false
    
    lazy var stackView: UIStackView! = {
        let stack = UIStackView()
        stack.axis = .Vertical
        stack.distribution = .Fill
        stack.alignment = .Fill
        stack.spacing = 3.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Vertical)
        return stack
    }()
    
    lazy var containerView: UIView! = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = false
        return view
    }()
    
    let productNameLabel = UILabel(frame: CGRectZero)
    let dateLabel = UILabel(frame: CGRectZero)
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
        productNameLabel.lineBreakMode = .ByWordWrapping
        productNameLabel.numberOfLines = 0
        
        dateLabel.textColor = .EDDBlackColor()
        dateLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        
        statusLabel.font = UIFont.systemFontOfSize(13, weight: UIFontWeightMedium)
        statusLabel.textColor = .whiteColor()
        statusLabel.layer.cornerRadius = 2
        statusLabel.layer.borderWidth = 1
        statusLabel.layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func layout() {
        stackView.addArrangedSubview(productNameLabel)
        stackView.addArrangedSubview(dateLabel)
        
        containerView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMarginsRelativeArrangement = true
        stackView.alignment = .Top
        
        contentView.addSubview(containerView)
        
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.sizeToFit()
        contentView.addSubview(statusLabel)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(productNameLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 0.7))
        constraints.append(NSLayoutConstraint(item: statusLabel, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .Trailing, multiplier: CGFloat(1), constant: -15))
        constraints.append(NSLayoutConstraint(item: statusLabel, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: CGFloat(1), constant: CGFloat(0)))
        constraints.append(containerView.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 0))
        constraints.append(containerView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor, constant: 0))
        constraints.append(containerView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 0))
        constraints.append(containerView.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor, constant: 0))
        constraints.append(stackView.topAnchor.constraintEqualToAnchor(containerView.topAnchor, constant: 15))
        constraints.append(stackView.bottomAnchor.constraintEqualToAnchor(containerView.bottomAnchor, constant: -15))
        constraints.append(stackView.leadingAnchor.constraintEqualToAnchor(containerView.leadingAnchor, constant: 15))
        constraints.append(stackView.trailingAnchor.constraintEqualToAnchor(containerView.trailingAnchor, constant: 15))
        
        NSLayoutConstraint.activateConstraints(constraints)
    }
    
    func configure(data: StoreCommissions) {
        productNameLabel.text = data.item
        
        dateLabel.text = sharedDateFormatter.stringFromDate(data.date)
        
        if data.status == "paid" {
            statusLabel.layer.backgroundColor = UIColor.validColor().CGColor
            statusLabel.layer.borderColor = UIColor.validColor().CGColor
        }
        
        if data.status == "unpaid" {
            statusLabel.layer.backgroundColor = UIColor.orangeColor().CGColor
            statusLabel.layer.borderColor = UIColor.orangeColor().CGColor
        }
        
        if data.status == "revoked" {
            statusLabel.layer.backgroundColor = UIColor.errorColor().CGColor
            statusLabel.layer.borderColor = UIColor.errorColor().CGColor
        }
        
        statusLabel.text = data.status.uppercaseString
        statusLabel.sizeToFit()
        
        layout()
    }
    
}
