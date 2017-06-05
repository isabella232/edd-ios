//
//  ProductsDetailStatsTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 25/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

class ProductsDetailStatsTableViewCell: UITableViewCell {

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
        return view
    }()
    
    fileprivate let totalLabel = UILabel(frame: CGRect.zero)
    fileprivate let totalStatsLabel = UILabel(frame: CGRect.zero)
    fileprivate let monthlyAverageLabel = UILabel(frame: CGRect.zero)
    fileprivate let monthlyAverageStatsLabel = UILabel(frame: CGRect.zero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        totalLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        totalLabel.textColor = .EDDBlueColor()
        totalLabel.text = NSLocalizedString("Total", comment: "")
        monthlyAverageLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        monthlyAverageLabel.textColor = .EDDBlueColor()
        monthlyAverageLabel.text = NSLocalizedString("Monthly Average", comment: "")
        
        totalStatsLabel.lineBreakMode = .byWordWrapping
        totalStatsLabel.numberOfLines = 0
        totalStatsLabel.textColor = .EDDBlackColor()
        totalStatsLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        monthlyAverageStatsLabel.lineBreakMode = .byWordWrapping
        monthlyAverageStatsLabel.numberOfLines = 0
        monthlyAverageStatsLabel.textColor = .EDDBlackColor()
        monthlyAverageStatsLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(_ stats: Data?) {
        let dict: Dictionary? = NSKeyedUnarchiver.unarchiveObject(with: stats!) as? [String : AnyObject]
        
        if let statsDict = dict {
            let total = statsDict["total"]!
            let totalSales = total["sales"] as! String
            
            let monthly = statsDict["monthly_average"]!
            let monthlyEarningsStat = monthly["earnings"]!
            let monthlyAverageSales = Int((monthly["sales"]! as AnyObject).doubleValue.rounded())
            let monthlyAverageEarnings = (monthlyEarningsStat! as AnyObject).doubleValue
            
            let totalStatsString = NSLocalizedString("Sales", comment: "") + ": \(totalSales)\n" + NSLocalizedString("Earnings", comment: "") + ": " + Site.currencyFormat(NSNumber(value: (total["earnings"] as! NSString).doubleValue))
            totalStatsLabel.text = totalStatsString
            
            let monthlyAverageStatsString = NSLocalizedString("Sales", comment: "") + ": " + String(describing: monthlyAverageSales) + "\n" + NSLocalizedString("Earnings", comment: "") + ": " + Site.currencyFormat(NSNumber(value: monthlyAverageEarnings!))
            monthlyAverageStatsLabel.text = monthlyAverageStatsString
            
            totalStatsLabel.sizeToFit()
            monthlyAverageStatsLabel.sizeToFit()
        }
        
        layout()
    }
    
    func layout() {
        stackView.addArrangedSubview(totalLabel)
        stackView.addArrangedSubview(totalStatsLabel)
        stackView.addArrangedSubview(monthlyAverageLabel)
        stackView.addArrangedSubview(monthlyAverageStatsLabel)
        
        containerView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.alignment = .top
        
        contentView.addSubview(containerView)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(totalLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(totalStatsLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(totalStatsLabel.bottomAnchor.constraint(equalTo: monthlyAverageLabel.topAnchor, constant: -20))
        constraints.append(monthlyAverageLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(monthlyAverageStatsLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10))
        constraints.append(containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10))
        constraints.append(containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10))
        constraints.append(containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10))
        constraints.append(stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10))
        constraints.append(stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10))
        constraints.append(stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10))
        constraints.append(stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10))
        
        NSLayoutConstraint.activate(constraints)
    }

}
