//
//  SalesDetailMetaTableViewCell.swift
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
    formatter.dateFormat = "EEE d MMM yyyy HH:mm:ss"
    return formatter
}()

class SalesDetailMetaTableViewCell: UITableViewCell {

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
    
    var sale: Sales!
    
    fileprivate var hasDiscounts = false
    fileprivate var hasFees = false
    
    fileprivate let titleLabel: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let transactionIdHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let transactionIdLabel: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let keyHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let keyLabel: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let dateHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let dateLabel: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let gatewayHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let gatewayLabel: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let discountHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let discountLabel: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let feesHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let feesLabel: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let taxHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let taxLabel: UILabel = UILabel(frame: CGRect.zero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.textColor = .EDDBlackColor()
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightBold)
        titleLabel.textAlignment = .left
        
        // Styling for headings
        transactionIdHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        transactionIdHeading.textColor = .EDDBlueColor()
        keyHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        keyHeading.textColor = .EDDBlueColor()
        dateHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        dateHeading.textColor = .EDDBlueColor()
        gatewayHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        gatewayHeading.textColor = .EDDBlueColor()
        discountHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        discountHeading.textColor = .EDDBlueColor()
        feesHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        feesHeading.textColor = .EDDBlueColor()
        taxHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        taxHeading.textColor = .EDDBlueColor()
        
        // Text for Headings
        transactionIdHeading.text = NSLocalizedString("Transaction ID", comment: "")
        keyHeading.text = NSLocalizedString("Key", comment: "")
        dateHeading.text = NSLocalizedString("Date", comment: "")
        gatewayHeading.text = NSLocalizedString("Gateway", comment: "")
        discountHeading.text = NSLocalizedString("Discount", comment: "")
        feesHeading.text = NSLocalizedString("Fees", comment: "")
        taxHeading.text = NSLocalizedString("Tax", comment: "")
        
        // Styling for labels
        transactionIdLabel.textColor = .EDDBlackColor()
        transactionIdLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        keyLabel.textColor = .EDDBlackColor()
        keyLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        dateLabel.textColor = .EDDBlackColor()
        dateLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        gatewayLabel.textColor = .EDDBlackColor()
        gatewayLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        discountLabel.textColor = .EDDBlackColor()
        discountLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        feesLabel.textColor = .EDDBlackColor()
        feesLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        taxLabel.textColor = .EDDBlackColor()
        taxLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(_ sale: Sales) {
        self.sale = sale
        
        let chargedText: String = NSLocalizedString("payment", comment: "")
        titleLabel.text = "\(Site.currencyFormat(sale.total! as NSNumber)) \(chargedText)"
        transactionIdLabel.text = sale.transactionId
        keyLabel.text = sale.key
        dateLabel.text = sharedDateFormatter.string(from: sale.date as Date)
        let firstCharacter = String(sale.gateway.characters.prefix(1)).uppercased()
        let gatewayCharacters = String(sale.gateway.characters.dropFirst())
        gatewayLabel.text = firstCharacter + gatewayCharacters
        
        if let discounts = sale.discounts {
            hasDiscounts = true
            
            if discounts.count > 1 {
                discountHeading.text = NSLocalizedString("Discount Codes", comment: "")
            } else {
                discountHeading.text = NSLocalizedString("Discount Code", comment: "")
            }
            var discountCodeString = ""
            for (key, _) in discounts {
                discountCodeString += key + " "
            }
            discountCodeString = String(discountCodeString.characters.dropLast())
            discountCodeString = discountCodeString.replacingOccurrences(of: " ", with: ", ")
            discountLabel.text = discountCodeString
        }
        
        if let fees = sale.fees {
            hasFees = true
            
            var feesString = ""
            
            for fee in fees {
                let label = fee["label"].stringValue
                let amount = fee["amount"].doubleValue
                feesString = label + ": " + Site.currencyFormat(NSNumber(value: amount)) + "\n"
            }

            feesLabel.text = feesString
        }
        
        if let tax = sale.tax {
            taxLabel.text = Site.currencyFormat(NSNumber(value: tax))
        }
        
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
        if hasDiscounts == true {
            stackView.addArrangedSubview(discountHeading)
            stackView.addArrangedSubview(discountLabel)
        }
        
        if hasFees == true {
            stackView.addArrangedSubview(feesHeading)
            stackView.addArrangedSubview(feesLabel)
        }
        
        if let _ = sale.tax {
            stackView.addArrangedSubview(taxHeading)
            stackView.addArrangedSubview(taxLabel)
        }

        containerView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.alignment = .top
        
        contentView.addSubview(containerView)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(titleLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(titleLabel.bottomAnchor.constraint(equalTo: transactionIdHeading.topAnchor, constant: -20))
        constraints.append(transactionIdHeading.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(transactionIdLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(transactionIdLabel.bottomAnchor.constraint(equalTo: keyHeading.topAnchor, constant: -20))
        constraints.append(keyHeading.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(keyLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(keyLabel.bottomAnchor.constraint(equalTo: dateHeading.topAnchor, constant: -20))
        constraints.append(dateHeading.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(dateLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(dateLabel.bottomAnchor.constraint(equalTo: gatewayHeading.topAnchor, constant: -20))
        constraints.append(gatewayHeading.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(gatewayLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        if hasDiscounts == true {
            constraints.append(gatewayLabel.bottomAnchor.constraint(equalTo: discountHeading.topAnchor, constant: -20))
            constraints.append(discountHeading.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
            constraints.append(discountLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        }
        if hasFees == true && hasDiscounts == true {
            constraints.append(discountLabel.bottomAnchor.constraint(equalTo: feesHeading.topAnchor, constant: -20))
            constraints.append(feesHeading.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
            constraints.append(feesLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
            if let _ = sale.tax {
                constraints.append(feesLabel.bottomAnchor.constraint(equalTo: taxHeading.topAnchor, constant: -20))
            }
        } else if hasFees == true && hasDiscounts == false {
            constraints.append(gatewayLabel.bottomAnchor.constraint(equalTo: feesHeading.topAnchor, constant: -20))
            constraints.append(feesHeading.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
            constraints.append(feesLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
            if let _ = sale.tax {
                constraints.append(feesLabel.bottomAnchor.constraint(equalTo: taxHeading.topAnchor, constant: -20))
            }
        } else if hasFees == false && hasDiscounts == false {
            if let _ = sale.tax {
                constraints.append(gatewayLabel.bottomAnchor.constraint(equalTo: taxHeading.topAnchor, constant: -20))
            }
        }
        
        if let _ = sale.tax {
            constraints.append(taxHeading.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
            constraints.append(taxLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        }
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
