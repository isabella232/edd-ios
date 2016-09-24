//
//  SalesDetailMetaTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 22/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

private let sharedDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    formatter.dateFormat = "EEE d MMM yyyy HH:mm:ss"
    return formatter
}()

class SalesDetailMetaTableViewCell: UITableViewCell {

    lazy var stackView : UIStackView! = {
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
    
    private let titleLabel: UILabel = UILabel(frame: CGRectZero)
    private let transactionIdHeading: UILabel = UILabel(frame: CGRectZero)
    private let transactionIdLabel: UILabel = UILabel(frame: CGRectZero)
    private let keyHeading: UILabel = UILabel(frame: CGRectZero)
    private let keyLabel: UILabel = UILabel(frame: CGRectZero)
    private let dateHeading: UILabel = UILabel(frame: CGRectZero)
    private let dateLabel: UILabel = UILabel(frame: CGRectZero)
    private let gatewayHeading: UILabel = UILabel(frame: CGRectZero)
    private let gatewayLabel: UILabel = UILabel(frame: CGRectZero)
    private let discountHeading: UILabel = UILabel(frame: CGRectZero)
    private let discountLabel: UILabel = UILabel(frame: CGRectZero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.textColor = .EDDBlackColor()
        titleLabel.font = UIFont.systemFontOfSize(20, weight: UIFontWeightBold)
        titleLabel.textAlignment = .Left
        
        // Styling for headings
        transactionIdHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        transactionIdHeading.textColor = .EDDBlueColor()
        keyHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        keyHeading.textColor = .EDDBlueColor()
        dateHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        dateHeading.textColor = .EDDBlueColor()
        gatewayHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        gatewayHeading.textColor = .EDDBlueColor()
        discountHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        discountHeading.textColor = .EDDBlueColor()
        
        // Text for Headings
        transactionIdHeading.text = NSLocalizedString("Transaction ID", comment: "")
        keyHeading.text = NSLocalizedString("Key", comment: "")
        dateHeading.text = NSLocalizedString("Date", comment: "")
        gatewayHeading.text = NSLocalizedString("Gateway", comment: "")
        discountHeading.text = NSLocalizedString("Discount", comment: "")
        
        // Styling for labels
        transactionIdLabel.textColor = .EDDBlackColor()
        transactionIdLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        keyLabel.textColor = .EDDBlackColor()
        keyLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        dateLabel.textColor = .EDDBlackColor()
        dateLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        gatewayLabel.textColor = .EDDBlackColor()
        gatewayLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        discountLabel.textColor = .EDDBlackColor()
        discountLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        
        selectionStyle = .None
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(sale: Sale) {        
        let chargedText: String = NSLocalizedString("payment", comment: "")
        titleLabel.text = "\(Site.currencyFormat(sale.total)) \(chargedText)"
        transactionIdLabel.text = sale.transactionId
        keyLabel.text = sale.key
        dateLabel.text = sharedDateFormatter.stringFromDate(sale.date)
        let firstCharacter = String(sale.gateway.characters.prefix(1)).uppercaseString
        let gatewayCharacters = String(sale.gateway.characters.dropFirst())
        gatewayLabel.text = firstCharacter + gatewayCharacters
        
        layout()
    }
    
    func layout() {
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(transactionIdHeading)
        stackView.addArrangedSubview(transactionIdLabel)
        stackView.addArrangedSubview(keyHeading)
        stackView.addArrangedSubview(keyLabel)
        stackView.addArrangedSubview(dateHeading)
        stackView.addArrangedSubview(dateLabel)
        stackView.addArrangedSubview(gatewayHeading)
        stackView.addArrangedSubview(gatewayLabel)

        containerView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMarginsRelativeArrangement = true
        stackView.alignment = .Top
        
        contentView.addSubview(containerView)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(titleLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(titleLabel.bottomAnchor.constraintEqualToAnchor(transactionIdHeading.topAnchor, constant: -20))
        constraints.append(transactionIdHeading.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(transactionIdLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(transactionIdLabel.bottomAnchor.constraintEqualToAnchor(keyHeading.topAnchor, constant: -20))
        constraints.append(keyHeading.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(keyLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(keyLabel.bottomAnchor.constraintEqualToAnchor(dateHeading.topAnchor, constant: -20))
        constraints.append(dateHeading.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(dateLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(dateLabel.bottomAnchor.constraintEqualToAnchor(gatewayHeading.topAnchor, constant: -20))
        constraints.append(gatewayHeading.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(gatewayLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
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

}
