//
//  StoreCommissionsDetailMetaTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 19/10/2016.
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

class StoreCommissionsDetailMetaTableViewCell: UITableViewCell {

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
    
    var commission: StoreCommissions?
    
    private let itemHeading: UILabel = UILabel(frame: CGRectZero)
    private let itemLabel: UILabel = UILabel(frame: CGRectZero)
    private let dateHeading: UILabel = UILabel(frame: CGRectZero)
    private let dateLabel: UILabel = UILabel(frame: CGRectZero)
    private let amountHeading: UILabel = UILabel(frame: CGRectZero)
    private let amountLabel: UILabel = UILabel(frame: CGRectZero)
    private let rateHeading: UILabel = UILabel(frame: CGRectZero)
    private let rateLabel: UILabel = UILabel(frame: CGRectZero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .None
        
        itemHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        itemHeading.textColor = .EDDBlueColor()
        itemLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        itemLabel.textColor = .EDDBlackColor()
        dateHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        dateHeading.textColor = .EDDBlueColor()
        dateLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        dateLabel.textColor = .EDDBlackColor()
        amountHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        amountHeading.textColor = .EDDBlueColor()
        amountLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        amountLabel.textColor = .EDDBlackColor()
        rateHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        rateHeading.textColor = .EDDBlueColor()
        rateLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        rateLabel.textColor = .EDDBlackColor()
        
        itemHeading.text = NSLocalizedString("Item", comment: "")
        dateHeading.text = NSLocalizedString("Date", comment: "")
        amountHeading.text = NSLocalizedString("Amount", comment: "")
        rateHeading.text = NSLocalizedString("Rate", comment: "")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(commission: StoreCommissions) {
        self.commission = commission
        
        itemLabel.text = commission.item
        dateLabel.text = sharedDateFormatter.stringFromDate(commission.date)
        amountLabel.text = Site.currencyFormat(commission.amount)
        rateLabel.text = "\(commission.rate)%"
        
        layout()
    }
    
    func layout() {
        stackView.addArrangedSubview(itemHeading)
        stackView.addArrangedSubview(itemLabel)
        stackView.addArrangedSubview(dateHeading)
        stackView.addArrangedSubview(dateLabel)
        stackView.addArrangedSubview(amountHeading)
        stackView.addArrangedSubview(amountLabel)
        stackView.addArrangedSubview(rateHeading)
        stackView.addArrangedSubview(rateLabel)
        
        containerView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMarginsRelativeArrangement = true
        stackView.alignment = .Top
        
        contentView.addSubview(containerView)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(itemHeading.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(itemLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(itemLabel.bottomAnchor.constraintEqualToAnchor(dateHeading.topAnchor, constant: -20))
        constraints.append(dateHeading.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(dateLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(dateLabel.bottomAnchor.constraintEqualToAnchor(amountHeading.topAnchor, constant: -20))
        constraints.append(amountHeading.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(amountLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(amountLabel.bottomAnchor.constraintEqualToAnchor(rateHeading.topAnchor, constant: -20))
        constraints.append(rateHeading.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(rateLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
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
