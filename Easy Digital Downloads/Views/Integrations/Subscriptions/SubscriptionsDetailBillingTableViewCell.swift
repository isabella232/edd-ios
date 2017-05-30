//
//  SubscriptionsDetailBillingTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 26/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import SwiftyJSON

private let sharedDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "EEE d MMM yyyy HH:mm:ss"
    return formatter
}()


class SubscriptionsDetailBillingTableViewCell: UITableViewCell {

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
    
    var subscription: Subscriptions!
    
    fileprivate let billingCycleHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let billingCycleText: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let timesBilledHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let timesBilledText: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let paymentMethodHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let paymentMethodText: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let profileHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let profileText: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let transactionIdHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let transactionIdText: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let dateCreatedHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let dateCreatedText: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let expirationDateHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let expirationDateText: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let statusHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let statusText: UILabel = UILabel(frame: CGRect.zero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        billingCycleHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        billingCycleHeading.textColor = .EDDBlueColor()
        billingCycleText.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        billingCycleText.textColor = .EDDBlackColor()
        timesBilledHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        timesBilledHeading.textColor = .EDDBlueColor()
        timesBilledText.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        timesBilledText.textColor = .EDDBlackColor()
        paymentMethodHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        paymentMethodHeading.textColor = .EDDBlueColor()
        paymentMethodText.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        paymentMethodText.textColor = .EDDBlackColor()
        profileHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        profileHeading.textColor = .EDDBlueColor()
        profileText.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        profileText.textColor = .EDDBlackColor()
        transactionIdHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        transactionIdHeading.textColor = .EDDBlueColor()
        transactionIdText.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        transactionIdText.textColor = .EDDBlackColor()
        dateCreatedHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        dateCreatedHeading.textColor = .EDDBlueColor()
        dateCreatedText.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        dateCreatedText.textColor = .EDDBlackColor()
        expirationDateHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        expirationDateHeading.textColor = .EDDBlueColor()
        expirationDateText.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        expirationDateText.textColor = .EDDBlackColor()
        statusHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        statusHeading.textColor = .EDDBlueColor()
        statusText.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        statusText.textColor = .EDDBlackColor()
        
        billingCycleHeading.text = NSLocalizedString("Billing Cycle", comment: "")
        timesBilledHeading.text = NSLocalizedString("Times Billed", comment: "")
        paymentMethodHeading.text = NSLocalizedString("Payment Method", comment: "")
        profileHeading.text = NSLocalizedString("Profile ID", comment: "")
        transactionIdHeading.text = NSLocalizedString("Transaction ID", comment: "")
        dateCreatedHeading.text = NSLocalizedString("Date Created", comment: "")
        expirationDateHeading.text = NSLocalizedString("Expiration Date", comment: "")
        statusHeading.text = NSLocalizedString("Status", comment: "")
        
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(_ subscription: Subscriptions) {
        self.subscription = subscription
        
        billingCycleText.text = Site.currencyFormat(subscription.initialAmount as! NSNumber) + " " + NSLocalizedString("then", comment: "") + " " + Site.currencyFormat(subscription.recurringAmount as! NSNumber)
        timesBilledText.text = "\(subscription.billTimes)"
        paymentMethodText.text = subscription.gateway.capitalized
        profileText.text = subscription.profileId
        dateCreatedText.text = sharedDateFormatter.string(from: subscription.created as Date)
        expirationDateText.text = sharedDateFormatter.string(from: subscription.expiration as Date)
        statusText.text = subscription.status.capitalized
        
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
        containerStackView.isLayoutMarginsRelativeArrangement = true
        containerStackView.alignment = .top
        
        contentView.addSubview(containerStackView)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(billingCycleHeading.widthAnchor.constraint(equalTo: containerStackView.widthAnchor, multiplier: 1.0))
        constraints.append(billingCycleText.widthAnchor.constraint(equalTo: containerStackView.widthAnchor, multiplier: 1.0))
        constraints.append(billingCycleText.bottomAnchor.constraint(equalTo: timesBilledHeading.topAnchor, constant: -20))
        constraints.append(timesBilledHeading.widthAnchor.constraint(equalTo: containerStackView.widthAnchor, multiplier: 1.0))
        constraints.append(timesBilledText.widthAnchor.constraint(equalTo: containerStackView.widthAnchor, multiplier: 1.0))
        constraints.append(timesBilledText.bottomAnchor.constraint(equalTo: paymentMethodHeading.topAnchor, constant: -20))
        constraints.append(paymentMethodHeading.widthAnchor.constraint(equalTo: containerStackView.widthAnchor, multiplier: 1.0))
        constraints.append(paymentMethodText.widthAnchor.constraint(equalTo: containerStackView.widthAnchor, multiplier: 1.0))
        constraints.append(paymentMethodText.bottomAnchor.constraint(equalTo: profileHeading.topAnchor, constant: -20))
        constraints.append(profileHeading.widthAnchor.constraint(equalTo: containerStackView.widthAnchor, multiplier: 1.0))
        constraints.append(profileText.widthAnchor.constraint(equalTo: containerStackView.widthAnchor, multiplier: 1.0))
        if let transactionId = subscription.transactionId {
            if transactionId.characters.count > 0 && transactionId != "false" {
                constraints.append(profileText.bottomAnchor.constraint(equalTo: transactionIdHeading.topAnchor, constant: -20))
                constraints.append(transactionIdHeading.widthAnchor.constraint(equalTo: containerStackView.widthAnchor, multiplier: 1.0))
                constraints.append(transactionIdText.widthAnchor.constraint(equalTo: containerStackView.widthAnchor, multiplier: 1.0))
                constraints.append(transactionIdText.bottomAnchor.constraint(equalTo: dateCreatedHeading.topAnchor, constant: -20))
            } else {
                constraints.append(profileText.bottomAnchor.constraint(equalTo: dateCreatedHeading.topAnchor, constant: -20))
            }
        }
        constraints.append(dateCreatedHeading.widthAnchor.constraint(equalTo: containerStackView.widthAnchor, multiplier: 1.0))
        constraints.append(dateCreatedText.widthAnchor.constraint(equalTo: containerStackView.widthAnchor, multiplier: 1.0))
        constraints.append(dateCreatedText.bottomAnchor.constraint(equalTo: expirationDateHeading.topAnchor, constant: -20))
        constraints.append(expirationDateHeading.widthAnchor.constraint(equalTo: containerStackView.widthAnchor, multiplier: 1.0))
        constraints.append(expirationDateText.widthAnchor.constraint(equalTo: containerStackView.widthAnchor, multiplier: 1.0))
        constraints.append(expirationDateText.bottomAnchor.constraint(equalTo: statusHeading.topAnchor, constant: -20))
        constraints.append(statusHeading.widthAnchor.constraint(equalTo: containerStackView.widthAnchor, multiplier: 1.0))
        constraints.append(statusText.widthAnchor.constraint(equalTo: containerStackView.widthAnchor, multiplier: 1.0))
        constraints.append(containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15))
        constraints.append(containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15))
        constraints.append(containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15))
        constraints.append(containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15))
        
        NSLayoutConstraint.activate(constraints)
    }
    
}
