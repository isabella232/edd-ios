//
//  FileDownloadLogsMetaTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 28/08/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import SwiftyJSON

private let sharedDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}()

class FileDownloadLogsMetaTableViewCell: UITableViewCell {
    
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
    
    private let titleLabel = UILabel(frame: CGRectZero)
    private let dataLabel = UILabel(frame: CGRectZero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .None
        
        dataLabel.textColor = .whiteColor()
        dataLabel.font = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
        dataLabel.numberOfLines = 0
        dataLabel.lineBreakMode = .ByWordWrapping
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func layout() {
        stackView.addArrangedSubview(dataLabel)
        
        containerView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMarginsRelativeArrangement = true
        stackView.alignment = .Top
        
        contentView.addSubview(containerView)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(containerView.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 10))
        constraints.append(containerView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor, constant: -10))
        constraints.append(containerView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 15))
        constraints.append(containerView.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor, constant: -15))
        constraints.append(stackView.topAnchor.constraintEqualToAnchor(containerView.topAnchor, constant: 10))
        constraints.append(stackView.bottomAnchor.constraintEqualToAnchor(containerView.bottomAnchor, constant: -10))
        constraints.append(stackView.leadingAnchor.constraintEqualToAnchor(containerView.leadingAnchor, constant: 10))
        constraints.append(stackView.trailingAnchor.constraintEqualToAnchor(containerView.trailingAnchor, constant: -10))
        
        NSLayoutConstraint.activateConstraints(constraints)
    }
    
    func configure(data: [String: AnyObject]) {
        let date = data["date"] as! String
        let dateObject = sharedDateFormatter.dateFromString(date)
        
        sharedDateFormatter.dateFormat = "EEE dd MMM yyyy HH:mm:ss"
        
        let dataText = "IP Address: \(data["ip"]!)" + "\n" +
                     "File: \(data["file"]!)" + "\n" +
                     "Date: \(sharedDateFormatter.stringFromDate(dateObject!))"
        
        dataLabel.text = dataText
        dataLabel.sizeToFit()
        
        // Reset date format
        sharedDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
}
