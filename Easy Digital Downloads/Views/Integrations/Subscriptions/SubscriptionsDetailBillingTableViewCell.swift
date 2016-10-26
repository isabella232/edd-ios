//
//  SubscriptionsDetailBillingTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 26/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import SwiftyJSON

private let sharedDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    formatter.dateFormat = "EEE d MMM yyyy HH:mm:ss"
    return formatter
}()


class SubscriptionsDetailBillingTableViewCell: UITableViewCell {

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
    
    var subscription: Subscriptions!
    
    private let billingCycleHeading: UILabel = UILabel(frame: CGRectZero)
    private let billingCycleText: UILabel = UILabel(frame: CGRectZero)
    private let timesBilledHeading: UILabel = UILabel(frame: CGRectZero)
    private let timesBilledText: UILabel = UILabel(frame: CGRectZero)
    private let paymentMethodHeading: UILabel = UILabel(frame: CGRectZero)
    private let paymentMethodText: UILabel = UILabel(frame: CGRectZero)
    private let profileHeading: UILabel = UILabel(frame: CGRectZero)
    private let profileText: UILabel = UILabel(frame: CGRectZero)
    private let transactionIdHeading: UILabel = UILabel(frame: CGRectZero)
    private let transactionIdText: UILabel = UILabel(frame: CGRectZero)
    private let dateCreatedHeading: UILabel = UILabel(frame: CGRectZero)
    private let dateCreatedText: UILabel = UILabel(frame: CGRectZero)
    private let expirationDateHeading: UILabel = UILabel(frame: CGRectZero)
    private let expirationDateText: UILabel = UILabel(frame: CGRectZero)
    private let statusHeading: UILabel = UILabel(frame: CGRectZero)
    private let statusText: UILabel = UILabel(frame: CGRectZero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        billingCycleHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        billingCycleHeading.textColor = .EDDBlueColor()
        billingCycleText.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        billingCycleText.textColor = .EDDBlackColor()
        timesBilledHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        timesBilledHeading.textColor = .EDDBlueColor()
        timesBilledText.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        timesBilledText.textColor = .EDDBlackColor()
        paymentMethodHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        paymentMethodHeading.textColor = .EDDBlueColor()
        paymentMethodText.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        paymentMethodText.textColor = .EDDBlackColor()
        profileHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        profileHeading.textColor = .EDDBlueColor()
        profileText.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        profileText.textColor = .EDDBlackColor()
        transactionIdHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        transactionIdHeading.textColor = .EDDBlueColor()
        transactionIdText.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        transactionIdText.textColor = .EDDBlackColor()
        dateCreatedHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        dateCreatedHeading.textColor = .EDDBlueColor()
        dateCreatedText.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        dateCreatedText.textColor = .EDDBlackColor()
        expirationDateHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        expirationDateHeading.textColor = .EDDBlueColor()
        expirationDateText.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        expirationDateText.textColor = .EDDBlackColor()
        statusHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        statusHeading.textColor = .EDDBlueColor()
        statusText.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        statusText.textColor = .EDDBlackColor()
        
        billingCycleHeading.text = NSLocalizedString("Billing Cycle", comment: "")
        timesBilledHeading.text = NSLocalizedString("Times Billed", comment: "")
        paymentMethodHeading.text = NSLocalizedString("Payment Method", comment: "")
        profileHeading.text = NSLocalizedString("Profile ID", comment: "")
        transactionIdHeading.text = NSLocalizedString("Transaction ID", comment: "")
        dateCreatedHeading.text = NSLocalizedString("Date Created", comment: "")
        expirationDateHeading.text = NSLocalizedString("Expiration Date", comment: "")
        statusHeading.text = NSLocalizedString("Status", comment: "")
        
        selectionStyle = .None
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(subscription: Subscriptions) {
        self.subscription = subscription
        
        billingCycleText.text = Site.currencyFormat(subscription.initialAmount) + " " + NSLocalizedString("then", comment: "") + " " + Site.currencyFormat(subscription.recurringAmount)
        timesBilledText.text = "\(subscription.billTimes)"
        paymentMethodText.text = subscription.gateway.capitalizedString
        profileText.text = subscription.profileId
        dateCreatedText.text = sharedDateFormatter.stringFromDate(subscription.created)
        expirationDateText.text = sharedDateFormatter.stringFromDate(subscription.expiration)
        statusText.text = subscription.status.capitalizedString
        
        if let transactionId = subscription.transactionId {
            if transactionId.characters.count > 0 && transactionId != "false" {
                transactionIdText.text = transactionId
            }
        }
        
        layout()
    }
    
    func layout() {
        containerStackView.addArrangedSubview(billingCycleHeading)
        containerStackView.addArrangedSubview(billingCycleText)
        containerStackView.addArrangedSubview(timesBilledHeading)
        containerStackView.addArrangedSubview(timesBilledText)
        containerStackView.addArrangedSubview(paymentMethodHeading)
        containerStackView.addArrangedSubview(paymentMethodText)
        containerStackView.addArrangedSubview(profileHeading)
        containerStackView.addArrangedSubview(profileText)
        
        if let transactionId = subscription.transactionId {
            if transactionId.characters.count > 0 && transactionId != "false" {
                containerStackView.addArrangedSubview(transactionIdHeading)
                containerStackView.addArrangedSubview(transactionIdText)
            }
        }
        
        containerStackView.addArrangedSubview(dateCreatedHeading)
        containerStackView.addArrangedSubview(dateCreatedText)
        containerStackView.addArrangedSubview(expirationDateHeading)
        containerStackView.addArrangedSubview(expirationDateText)
        containerStackView.addArrangedSubview(statusHeading)
        containerStackView.addArrangedSubview(statusText)
        
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.layoutMarginsRelativeArrangement = true
        containerStackView.alignment = .Top
        
        contentView.addSubview(containerStackView)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(billingCycleHeading.widthAnchor.constraintEqualToAnchor(containerStackView.widthAnchor, multiplier: 1.0))
        constraints.append(billingCycleText.widthAnchor.constraintEqualToAnchor(containerStackView.widthAnchor, multiplier: 1.0))
        constraints.append(billingCycleText.bottomAnchor.constraintEqualToAnchor(timesBilledHeading.topAnchor, constant: -20))
        constraints.append(timesBilledHeading.widthAnchor.constraintEqualToAnchor(containerStackView.widthAnchor, multiplier: 1.0))
        constraints.append(timesBilledText.widthAnchor.constraintEqualToAnchor(containerStackView.widthAnchor, multiplier: 1.0))
        constraints.append(timesBilledText.bottomAnchor.constraintEqualToAnchor(paymentMethodHeading.topAnchor, constant: -20))
        constraints.append(paymentMethodHeading.widthAnchor.constraintEqualToAnchor(containerStackView.widthAnchor, multiplier: 1.0))
        constraints.append(paymentMethodText.widthAnchor.constraintEqualToAnchor(containerStackView.widthAnchor, multiplier: 1.0))
        constraints.append(paymentMethodText.bottomAnchor.constraintEqualToAnchor(profileHeading.topAnchor, constant: -20))
        constraints.append(profileHeading.widthAnchor.constraintEqualToAnchor(containerStackView.widthAnchor, multiplier: 1.0))
        constraints.append(profileText.widthAnchor.constraintEqualToAnchor(containerStackView.widthAnchor, multiplier: 1.0))
        if let transactionId = subscription.transactionId {
            if transactionId.characters.count > 0 && transactionId != "false" {
                constraints.append(profileText.bottomAnchor.constraintEqualToAnchor(transactionIdHeading.topAnchor, constant: -20))
                constraints.append(transactionIdHeading.widthAnchor.constraintEqualToAnchor(containerStackView.widthAnchor, multiplier: 1.0))
                constraints.append(transactionIdText.widthAnchor.constraintEqualToAnchor(containerStackView.widthAnchor, multiplier: 1.0))
                constraints.append(transactionIdText.bottomAnchor.constraintEqualToAnchor(dateCreatedHeading.topAnchor, constant: -20))
            } else {
                constraints.append(profileText.bottomAnchor.constraintEqualToAnchor(dateCreatedHeading.topAnchor, constant: -20))
            }
        }
        constraints.append(dateCreatedHeading.widthAnchor.constraintEqualToAnchor(containerStackView.widthAnchor, multiplier: 1.0))
        constraints.append(dateCreatedText.widthAnchor.constraintEqualToAnchor(containerStackView.widthAnchor, multiplier: 1.0))
        constraints.append(dateCreatedText.bottomAnchor.constraintEqualToAnchor(expirationDateHeading.topAnchor, constant: -20))
        constraints.append(expirationDateHeading.widthAnchor.constraintEqualToAnchor(containerStackView.widthAnchor, multiplier: 1.0))
        constraints.append(expirationDateText.widthAnchor.constraintEqualToAnchor(containerStackView.widthAnchor, multiplier: 1.0))
        constraints.append(expirationDateText.bottomAnchor.constraintEqualToAnchor(statusHeading.topAnchor, constant: -20))
        constraints.append(statusHeading.widthAnchor.constraintEqualToAnchor(containerStackView.widthAnchor, multiplier: 1.0))
        constraints.append(statusText.widthAnchor.constraintEqualToAnchor(containerStackView.widthAnchor, multiplier: 1.0))
        constraints.append(containerStackView.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 15))
        constraints.append(containerStackView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor, constant: -15))
        constraints.append(containerStackView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 15))
        constraints.append(containerStackView.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor, constant: -15))
        
        NSLayoutConstraint.activateConstraints(constraints)
    }
    
}
