//
//  SubscriptionsTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 22/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import SwiftyJSON

private let sharedDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    formatter.dateFormat = "EEE dd MMM yyyy HH:mm"
    return formatter
}()

class SubscriptionsTableViewCell: UITableViewCell {

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
    
    let nameLabel: UILabel = UILabel(frame: CGRectZero)
    let dateLabel: UILabel = UILabel(frame: CGRectZero)
    let disclosureImageView: UIImageView = UIImageView(image: UIImage(named: "DisclosureIndicator"))
    let statusLabel = CommissionsStatusLabel(frame: CGRectZero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
        layer.opaque = true
        opaque = true
        
        backgroundColor = .clearColor()
        contentView.backgroundColor = .clearColor()
        
        nameLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        nameLabel.textColor = .EDDBlueColor()
        
        dateLabel.textColor = .EDDBlackColor()
        dateLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        
        statusLabel.font = UIFont.systemFontOfSize(13, weight: UIFontWeightMedium)
        statusLabel.textColor = .whiteColor()
        statusLabel.layer.cornerRadius = 2
        statusLabel.layer.borderWidth = 1
        statusLabel.layer.masksToBounds = true
        
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Private
    
    private func layout() {
        containerStackView.addArrangedSubview(nameLabel)
        containerStackView.addArrangedSubview(dateLabel)
        
        contentView.addSubview(containerStackView)
        
        disclosureImageView.translatesAutoresizingMaskIntoConstraints = false
        disclosureImageView.sizeToFit()
        contentView.addSubview(disclosureImageView)
        
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.sizeToFit()
        contentView.addSubview(statusLabel)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: disclosureImageView, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .Trailing, multiplier: CGFloat(1), constant: -15))
        constraints.append(NSLayoutConstraint(item: disclosureImageView, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: CGFloat(1), constant: CGFloat(0)))
        constraints.append(NSLayoutConstraint(item: statusLabel, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .Trailing, multiplier: CGFloat(1), constant: -45))
        constraints.append(NSLayoutConstraint(item: statusLabel, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: CGFloat(1), constant: CGFloat(0)))
        constraints.append(containerStackView.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 15))
        constraints.append(containerStackView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor, constant: -15))
        constraints.append(containerStackView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 15))
        constraints.append(containerStackView.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor, constant: -15))
        
        NSLayoutConstraint.activateConstraints(constraints)
    }
    
    func configure(subscription: Subscriptions) {
        let customer = subscription.customer
        
        var name = customer["name"]!.stringValue
        
        if name.characters.count == 0 {
            name = customer["email"]!.stringValue
        }
        
        if subscription.status == "cancelled" || subscription.status == "expired" || subscription.status == "failing" {
            statusLabel.layer.backgroundColor = UIColor.errorColor().CGColor
            statusLabel.layer.borderColor = UIColor.errorColor().CGColor
        }
        
        if subscription.status == "pending" {
            statusLabel.layer.backgroundColor = UIColor.orangeColor().CGColor
            statusLabel.layer.borderColor = UIColor.orangeColor().CGColor
        }
        
        if subscription.status == "active" {
            statusLabel.layer.backgroundColor = UIColor.validColor().CGColor
            statusLabel.layer.borderColor = UIColor.validColor().CGColor
        }
        
        statusLabel.text = subscription.status.uppercaseString
        
        nameLabel.text = name
        dateLabel.text = sharedDateFormatter.stringFromDate(subscription.created)
    }

}
