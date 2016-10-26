//
//  DiscountsDetailMetaTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 18/10/2016.
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

class DiscountsDetailMetaTableViewCell: UITableViewCell {

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
    
    var discount: Discounts!
    
    private let nameHeading: UILabel = UILabel(frame: CGRectZero)
    private let nameLabel: UILabel = UILabel(frame: CGRectZero)
    private let codeHeading: UILabel = UILabel(frame: CGRectZero)
    private let codeLabel: UILabel = UILabel(frame: CGRectZero)
    private let amountHeading: UILabel = UILabel(frame: CGRectZero)
    private let amountLabel: UILabel = UILabel(frame: CGRectZero)
    private let minPriceHeading: UILabel = UILabel(frame: CGRectZero)
    private let minPriceLabel: UILabel = UILabel(frame: CGRectZero)
    private let startDateHeading: UILabel = UILabel(frame: CGRectZero)
    private let startDateLabel: UILabel = UILabel(frame: CGRectZero)
    private let expDateHeading: UILabel = UILabel(frame: CGRectZero)
    private let expDateLabel: UILabel = UILabel(frame: CGRectZero)
    private let statusHeading: UILabel = UILabel(frame: CGRectZero)
    private let statusLabel: UILabel = UILabel(frame: CGRectZero)
    private let requirementsConditionHeading: UILabel = UILabel(frame: CGRectZero)
    private let requirementsConditionLabel: UILabel = UILabel(frame: CGRectZero)
    private let globalDiscountHeading: UILabel = UILabel(frame: CGRectZero)
    private let globalDiscountLabel: UILabel = UILabel(frame: CGRectZero)
    private let singleUseHeading: UILabel = UILabel(frame: CGRectZero)
    private let singleUseLabel: UILabel = UILabel(frame: CGRectZero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Styling for headings
        nameHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        nameHeading.textColor = .EDDBlueColor()
        codeHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        codeHeading.textColor = .EDDBlueColor()
        amountHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        amountHeading.textColor = .EDDBlueColor()
        minPriceHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        minPriceHeading.textColor = .EDDBlueColor()
        startDateHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        startDateHeading.textColor = .EDDBlueColor()
        expDateHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        expDateHeading.textColor = .EDDBlueColor()
        statusHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        statusHeading.textColor = .EDDBlueColor()
        requirementsConditionHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        requirementsConditionHeading.textColor = .EDDBlueColor()
        globalDiscountHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        globalDiscountHeading.textColor = .EDDBlueColor()
        singleUseHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        singleUseHeading.textColor = .EDDBlueColor()
        
        // Text for Headings
        nameHeading.text = NSLocalizedString("Name", comment: "")
        codeHeading.text = NSLocalizedString("Code", comment: "")
        amountHeading.text = NSLocalizedString("Amount", comment: "")
        minPriceHeading.text = NSLocalizedString("Minimum Price", comment: "")
        startDateHeading.text = NSLocalizedString("Start Date", comment: "")
        expDateHeading.text = NSLocalizedString("Expiry Date", comment: "")
        statusHeading.text = NSLocalizedString("Status", comment: "")
        requirementsConditionHeading.text = NSLocalizedString("Requirement Condition", comment: "")
        globalDiscountHeading.text = NSLocalizedString("Global Discount?", comment: "")
        singleUseHeading.text = NSLocalizedString("Single Use?", comment: "")
        
        // Styling for labels
        nameLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        nameLabel.textColor = .EDDBlackColor()
        codeLabel.font = UIFont(name: "Menlo-Regular", size: 13)
        codeLabel.textColor = .EDDBlackColor()
        amountLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        amountLabel.textColor = .EDDBlackColor()
        minPriceLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        minPriceLabel.textColor = .EDDBlackColor()
        startDateLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        startDateLabel.textColor = .EDDBlackColor()
        expDateLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        expDateLabel.textColor = .EDDBlackColor()
        statusLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        statusLabel.textColor = .EDDBlackColor()
        requirementsConditionLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        requirementsConditionLabel.textColor = .EDDBlackColor()
        globalDiscountLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        globalDiscountLabel.textColor = .EDDBlackColor()
        singleUseLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        singleUseLabel.textColor = .EDDBlackColor()
        
        selectionStyle = .None
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(discount: Discounts) {
        self.discount = discount
        
        nameLabel.text = discount.name
        codeLabel.text = discount.code
        
        if discount.type == "flat" {
            amountLabel.text = Site.currencyFormat(discount.amount)
        } else {
            amountLabel.text = "\(Int(discount.amount))%"
        }
        
        if discount.minPrice == 0 {
            minPriceLabel.text = NSLocalizedString("No minimum amount", comment: "")
        } else {
            minPriceLabel.text = Site.currencyFormat(discount.minPrice)
        }
        
        if let startDate = discount.startDate {
            startDateLabel.text = sharedDateFormatter.stringFromDate(startDate)
        } else {
            startDateLabel.text = NSLocalizedString("No start date", comment: "")
        }
        
        if let expiryDate = discount.expiryDate {
            expDateLabel.text = sharedDateFormatter.stringFromDate(expiryDate)
        } else {
            expDateLabel.text = NSLocalizedString("No expiration", comment: "")
        }
        
        statusLabel.text = discount.status.capitalizedString
        requirementsConditionLabel.text = discount.requirementCondition.capitalizedString
        
        if !discount.globalDiscount {
            globalDiscountLabel.text = NSLocalizedString("No", comment: "")
        } else {
            globalDiscountLabel.text = NSLocalizedString("Yes", comment: "")
        }
        
        if !discount.singleUse {
            singleUseLabel.text = NSLocalizedString("No", comment: "")
        } else {
            singleUseLabel.text = NSLocalizedString("Yes", comment: "")
        }
        
        layout()
    }
    
    func layout() {
        stackView.addArrangedSubview(nameHeading)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(codeHeading)
        stackView.addArrangedSubview(codeLabel)
        stackView.addArrangedSubview(amountHeading)
        stackView.addArrangedSubview(amountLabel)
        stackView.addArrangedSubview(minPriceHeading)
        stackView.addArrangedSubview(minPriceLabel)
        stackView.addArrangedSubview(startDateHeading)
        stackView.addArrangedSubview(startDateLabel)
        stackView.addArrangedSubview(expDateHeading)
        stackView.addArrangedSubview(expDateLabel)
        stackView.addArrangedSubview(statusHeading)
        stackView.addArrangedSubview(statusLabel)
        
        if self.discount.requirementCondition.characters.count > 0 {
            stackView.addArrangedSubview(requirementsConditionHeading)
            stackView.addArrangedSubview(requirementsConditionLabel)
        }
        stackView.addArrangedSubview(globalDiscountHeading)
        stackView.addArrangedSubview(globalDiscountLabel)
        stackView.addArrangedSubview(singleUseHeading)
        stackView.addArrangedSubview(singleUseLabel)
        
        containerView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMarginsRelativeArrangement = true
        stackView.alignment = .Top
        
        contentView.addSubview(containerView)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(nameHeading.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(nameLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(nameLabel.bottomAnchor.constraintEqualToAnchor(codeHeading.topAnchor, constant: -20))
        constraints.append(codeHeading.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(codeLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(codeLabel.bottomAnchor.constraintEqualToAnchor(amountHeading.topAnchor, constant: -20))
        constraints.append(amountHeading.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(amountLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(amountLabel.bottomAnchor.constraintEqualToAnchor(minPriceHeading.topAnchor, constant: -20))
        constraints.append(minPriceHeading.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(minPriceLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(minPriceLabel.bottomAnchor.constraintEqualToAnchor(startDateHeading.topAnchor, constant: -20))
        constraints.append(startDateHeading.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(startDateLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(startDateLabel.bottomAnchor.constraintEqualToAnchor(expDateHeading.topAnchor, constant: -20))
        constraints.append(expDateHeading.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(expDateLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(expDateLabel.bottomAnchor.constraintEqualToAnchor(statusHeading.topAnchor, constant: -20))
        constraints.append(statusHeading.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(statusLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        if self.discount.requirementCondition.characters.count > 0 {
            constraints.append(statusLabel.bottomAnchor.constraintEqualToAnchor(requirementsConditionHeading.topAnchor, constant: -20))
            constraints.append(requirementsConditionHeading.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
            constraints.append(requirementsConditionLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
            constraints.append(requirementsConditionLabel.bottomAnchor.constraintEqualToAnchor(globalDiscountHeading.topAnchor, constant: -20))
        } else {
            constraints.append(statusLabel.bottomAnchor.constraintEqualToAnchor(globalDiscountHeading.topAnchor, constant: -20))
        }
        constraints.append(globalDiscountHeading.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(globalDiscountLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(globalDiscountLabel.bottomAnchor.constraintEqualToAnchor(singleUseHeading.topAnchor, constant: -20))
        constraints.append(singleUseHeading.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(singleUseLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
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
