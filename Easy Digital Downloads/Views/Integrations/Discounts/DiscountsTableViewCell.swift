//
//  DiscountsTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 03/10/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

private let sharedDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "EEE dd MMM yyyy HH:mm:ss"
    return formatter
}()


class DiscountsTableViewCell: UITableViewCell {

    var hasSetupConstraints = false
    
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
    
    let productNameLabel = UILabel(frame: CGRect.zero)
    let codeLabel = UILabel(frame: CGRect.zero)
    let statusLabel = CommissionsStatusLabel(frame: CGRect.zero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.isOpaque = true
        isOpaque = true
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        productNameLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        productNameLabel.textColor = .EDDBlueColor()
        
        codeLabel.textColor = .EDDBlackColor()
        codeLabel.font = UIFont(name: "Menlo-Regular", size: 13)
        
        statusLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFontWeightMedium)
        statusLabel.textColor = .white
        statusLabel.layer.cornerRadius = 2
        statusLabel.layer.borderWidth = 1
        statusLabel.layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func layout() {
        containerStackView.addArrangedSubview(productNameLabel)
        containerStackView.addArrangedSubview(codeLabel)
        
        contentView.addSubview(containerStackView)
        
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.sizeToFit()
        contentView.addSubview(statusLabel)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: statusLabel, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: CGFloat(1), constant: -15))
        constraints.append(NSLayoutConstraint(item: statusLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: CGFloat(1), constant: CGFloat(0)))
        constraints.append(containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15))
        constraints.append(containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15))
        constraints.append(containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15))
        constraints.append(containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func configure(_ data: Discounts) {
        productNameLabel.text = data.name
        codeLabel.text = data.code
        
        if data.status == "active" {
            statusLabel.layer.backgroundColor = UIColor.validColor().cgColor
            statusLabel.layer.borderColor = UIColor.validColor().cgColor
        }
        
        if data.status == "inactive" {
            statusLabel.layer.backgroundColor = UIColor.errorColor().cgColor
            statusLabel.layer.borderColor = UIColor.errorColor().cgColor
        }
        
        statusLabel.text = data.status.uppercased()
        statusLabel.sizeToFit()
        
        layout()
    }

}
