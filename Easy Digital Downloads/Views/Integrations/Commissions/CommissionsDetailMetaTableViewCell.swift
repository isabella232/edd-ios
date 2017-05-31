//
//  CommissionsDetailMetaTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 19/10/2016.
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

class CommissionsDetailMetaTableViewCell: UITableViewCell {

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
    
    var commission: Commissions?
    
    fileprivate let itemHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let itemLabel: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let dateHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let dateLabel: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let amountHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let amountLabel: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let rateHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let rateLabel: UILabel = UILabel(frame: CGRect.zero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        itemHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        itemHeading.textColor = .EDDBlueColor()
        itemLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        itemLabel.textColor = .EDDBlackColor()
        dateHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        dateHeading.textColor = .EDDBlueColor()
        dateLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        dateLabel.textColor = .EDDBlackColor()
        amountHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        amountHeading.textColor = .EDDBlueColor()
        amountLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        amountLabel.textColor = .EDDBlackColor()
        rateHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        rateHeading.textColor = .EDDBlueColor()
        rateLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        rateLabel.textColor = .EDDBlackColor()
        
        itemHeading.text = NSLocalizedString("Item", comment: "")
        dateHeading.text = NSLocalizedString("Date", comment: "")
        amountHeading.text = NSLocalizedString("Amount", comment: "")
        rateHeading.text = NSLocalizedString("Rate", comment: "")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ commission: Commissions) {
        self.commission = commission
        
        itemLabel.text = commission.item
        dateLabel.text = sharedDateFormatter.string(from: commission.date as Date)
        amountLabel.text = Site.currencyFormat(NSNumber(value: commission.amount))
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
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.alignment = .top
        
        contentView.addSubview(containerView)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(itemHeading.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(itemLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(itemLabel.bottomAnchor.constraint(equalTo: dateHeading.topAnchor, constant: -20))
        constraints.append(dateHeading.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(dateLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(dateLabel.bottomAnchor.constraint(equalTo: amountHeading.topAnchor, constant: -20))
        constraints.append(amountHeading.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(amountLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(amountLabel.bottomAnchor.constraint(equalTo: rateHeading.topAnchor, constant: -20))
        constraints.append(rateHeading.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(rateLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
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
