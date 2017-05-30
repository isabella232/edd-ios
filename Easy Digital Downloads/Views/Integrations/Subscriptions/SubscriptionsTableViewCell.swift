//
//  SubscriptionsTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 22/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import SwiftyJSON

private let sharedDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "EEE dd MMM yyyy HH:mm"
    return formatter
}()

class SubscriptionsTableViewCell: UITableViewCell {

    fileprivate var hasSetupConstraints = false
    
    lazy var stackView: UIStackView! = {
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
        view.layer.masksToBounds = false
        return view
    }()
    
    let nameLabel: UILabel = UILabel(frame: CGRect.zero)
    let dateLabel: UILabel = UILabel(frame: CGRect.zero)
    let disclosureImageView: UIImageView = UIImageView(image: UIImage(named: "DisclosureIndicator"))
    let statusLabel = CommissionsStatusLabel(frame: CGRect.zero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.isOpaque = true
        isOpaque = true
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        nameLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        nameLabel.textColor = .EDDBlueColor()
        nameLabel.lineBreakMode = .byWordWrapping
        nameLabel.numberOfLines = 0
        
        dateLabel.textColor = .EDDBlackColor()
        dateLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        
        statusLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFontWeightMedium)
        statusLabel.textColor = .white
        statusLabel.layer.cornerRadius = 2
        statusLabel.layer.borderWidth = 1
        statusLabel.layer.masksToBounds = true
        
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Private
    
    fileprivate func layout() {
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(dateLabel)
        
        containerView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.alignment = .top
        
        contentView.addSubview(containerView)
        
        disclosureImageView.translatesAutoresizingMaskIntoConstraints = false
        disclosureImageView.sizeToFit()
        contentView.addSubview(disclosureImageView)
        
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.sizeToFit()
        contentView.addSubview(statusLabel)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: disclosureImageView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: CGFloat(1), constant: -15))
        constraints.append(NSLayoutConstraint(item: disclosureImageView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: CGFloat(1), constant: CGFloat(0)))
        constraints.append(NSLayoutConstraint(item: statusLabel, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: CGFloat(1), constant: -45))
        constraints.append(NSLayoutConstraint(item: statusLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: CGFloat(1), constant: CGFloat(0)))
        constraints.append(containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0))
        constraints.append(containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0))
        constraints.append(containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0))
        constraints.append(containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0))
        constraints.append(stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15))
        constraints.append(stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15))
        constraints.append(stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15))
        constraints.append(stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 15))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func configure(_ subscription: Subscriptions) {
        let customer = subscription.customer
        
        var name = customer?["name"]!.stringValue
        
        if name?.characters.count == 0 {
            name = customer?["email"]!.stringValue
        }
        
        if subscription.status == "cancelled" || subscription.status == "expired" || subscription.status == "failing" {
            statusLabel.layer.backgroundColor = UIColor.errorColor().cgColor
            statusLabel.layer.borderColor = UIColor.errorColor().cgColor
        }
        
        if subscription.status == "pending" {
            statusLabel.layer.backgroundColor = UIColor.orange.cgColor
            statusLabel.layer.borderColor = UIColor.orange.cgColor
        }
        
        if subscription.status == "active" || subscription.status == "completed" {
            statusLabel.layer.backgroundColor = UIColor.validColor().cgColor
            statusLabel.layer.borderColor = UIColor.validColor().cgColor
        }
        
        statusLabel.text = subscription.status.uppercased()
        
        nameLabel.text = name
        dateLabel.text = sharedDateFormatter.string(from: subscription.created as Date)
        
        nameLabel.sizeToFit()
        dateLabel.sizeToFit()
    }

}
