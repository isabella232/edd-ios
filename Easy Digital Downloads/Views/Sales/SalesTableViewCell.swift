//
//  SalesTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 21/08/2016.
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

final class SalesTableViewCell: UITableViewCell {
    
    fileprivate var hasSetupConstraints = false
    
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

    let amountLabel: UILabel = UILabel(frame: CGRect.zero)
    let dateLabel: UILabel = UILabel(frame: CGRect.zero)
    let disclosureImageView: UIImageView = UIImageView(image: UIImage(named: "DisclosureIndicator"))
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.isOpaque = true
        isOpaque = true
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        amountLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        amountLabel.textColor = .EDDBlueColor()
        
        dateLabel.textColor = .EDDBlackColor()
        dateLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Private
    
    fileprivate func layout() {
        containerStackView.addArrangedSubview(amountLabel)
        containerStackView.addArrangedSubview(dateLabel)
        
        contentView.addSubview(containerStackView)
    
        disclosureImageView.translatesAutoresizingMaskIntoConstraints = false
        disclosureImageView.sizeToFit()
        contentView.addSubview(disclosureImageView)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: disclosureImageView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: CGFloat(1), constant: -15))
        constraints.append(NSLayoutConstraint(item: disclosureImageView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: CGFloat(1), constant: CGFloat(0)))
        constraints.append(containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15))
        constraints.append(containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15))
        constraints.append(containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15))
        constraints.append(containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func configure(_ sale: Sales) {
        let chargedText: String = NSLocalizedString("charged", comment: "")
        amountLabel.text = "\(Site.currencyFormat(NSNumber(value: sale.total))) \(chargedText)"
        
        let reformattedDate = sharedDateFormatter.string(from: sale.date as Date)
        dateLabel.text = reformattedDate
        dateLabel.sizeToFit()
    }
    
}
