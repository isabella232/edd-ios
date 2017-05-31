//
//  DiscountsDetailMetaTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 18/10/2016.
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

class DiscountsDetailMetaTableViewCell: UITableViewCell {

    lazy var stackView : UIStackView! = {
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
    
    var discount: Discounts!
    
    fileprivate let nameHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let nameLabel: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let codeHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let codeLabel: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let amountHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let amountLabel: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let minPriceHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let minPriceLabel: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let startDateHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let startDateLabel: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let expDateHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let expDateLabel: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let statusHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let statusLabel: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let requirementsConditionHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let requirementsConditionLabel: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let globalDiscountHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let globalDiscountLabel: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let singleUseHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let singleUseLabel: UILabel = UILabel(frame: CGRect.zero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Styling for headings
        nameHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        nameHeading.textColor = .EDDBlueColor()
        codeHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        codeHeading.textColor = .EDDBlueColor()
        amountHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        amountHeading.textColor = .EDDBlueColor()
        minPriceHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        minPriceHeading.textColor = .EDDBlueColor()
        startDateHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        startDateHeading.textColor = .EDDBlueColor()
        expDateHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        expDateHeading.textColor = .EDDBlueColor()
        statusHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        statusHeading.textColor = .EDDBlueColor()
        requirementsConditionHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        requirementsConditionHeading.textColor = .EDDBlueColor()
        globalDiscountHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        globalDiscountHeading.textColor = .EDDBlueColor()
        singleUseHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
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
        nameLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        nameLabel.textColor = .EDDBlackColor()
        codeLabel.font = UIFont(name: "Menlo-Regular", size: 13)
        codeLabel.textColor = .EDDBlackColor()
        amountLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        amountLabel.textColor = .EDDBlackColor()
        minPriceLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        minPriceLabel.textColor = .EDDBlackColor()
        startDateLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        startDateLabel.textColor = .EDDBlackColor()
        expDateLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        expDateLabel.textColor = .EDDBlackColor()
        statusLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        statusLabel.textColor = .EDDBlackColor()
        requirementsConditionLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        requirementsConditionLabel.textColor = .EDDBlackColor()
        globalDiscountLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        globalDiscountLabel.textColor = .EDDBlackColor()
        singleUseLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        singleUseLabel.textColor = .EDDBlackColor()
        
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(_ discount: Discounts) {
        self.discount = discount
        
        nameLabel.text = discount.name
        codeLabel.text = discount.code
        
        if discount.type == "flat" {
            amountLabel.text = Site.currencyFormat(discount.amount as! NSNumber)
        } else {
            amountLabel.text = "\(Int(discount.amount))%"
        }
        
        if discount.minPrice == 0 {
            minPriceLabel.text = NSLocalizedString("No minimum amount", comment: "")
        } else {
            minPriceLabel.text = Site.currencyFormat(discount.minPrice as! NSNumber)
        }
        
        if let startDate = discount.startDate {
            startDateLabel.text = sharedDateFormatter.string(from: startDate as Date)
        } else {
            startDateLabel.text = NSLocalizedString("No start date", comment: "")
        }
        
        if let expiryDate = discount.expiryDate {
            expDateLabel.text = sharedDateFormatter.string(from: expiryDate as Date)
        } else {
            expDateLabel.text = NSLocalizedString("No expiration", comment: "")
        }
        
        statusLabel.text = discount.status.capitalized
        requirementsConditionLabel.text = discount.requirementCondition.capitalized
        
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
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.alignment = .top
        
        contentView.addSubview(containerView)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(nameHeading.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(nameLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(nameLabel.bottomAnchor.constraint(equalTo: codeHeading.topAnchor, constant: -20))
        constraints.append(codeHeading.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(codeLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(codeLabel.bottomAnchor.constraint(equalTo: amountHeading.topAnchor, constant: -20))
        constraints.append(amountHeading.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(amountLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(amountLabel.bottomAnchor.constraint(equalTo: minPriceHeading.topAnchor, constant: -20))
        constraints.append(minPriceHeading.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(minPriceLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(minPriceLabel.bottomAnchor.constraint(equalTo: startDateHeading.topAnchor, constant: -20))
        constraints.append(startDateHeading.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(startDateLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(startDateLabel.bottomAnchor.constraint(equalTo: expDateHeading.topAnchor, constant: -20))
        constraints.append(expDateHeading.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(expDateLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(expDateLabel.bottomAnchor.constraint(equalTo: statusHeading.topAnchor, constant: -20))
        constraints.append(statusHeading.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(statusLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        if self.discount.requirementCondition.characters.count > 0 {
            constraints.append(statusLabel.bottomAnchor.constraint(equalTo: requirementsConditionHeading.topAnchor, constant: -20))
            constraints.append(requirementsConditionHeading.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
            constraints.append(requirementsConditionLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
            constraints.append(requirementsConditionLabel.bottomAnchor.constraint(equalTo: globalDiscountHeading.topAnchor, constant: -20))
        } else {
            constraints.append(statusLabel.bottomAnchor.constraint(equalTo: globalDiscountHeading.topAnchor, constant: -20))
        }
        constraints.append(globalDiscountHeading.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(globalDiscountLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(globalDiscountLabel.bottomAnchor.constraint(equalTo: singleUseHeading.topAnchor, constant: -20))
        constraints.append(singleUseHeading.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(singleUseLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
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
    
}
