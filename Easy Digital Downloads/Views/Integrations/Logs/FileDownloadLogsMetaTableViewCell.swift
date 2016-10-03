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
    
    private let ipHeading: UILabel = UILabel(frame: CGRectZero)
    private let ipLabel: UILabel = UILabel(frame: CGRectZero)
    private let fileHeading: UILabel = UILabel(frame: CGRectZero)
    private let fileLabel: UILabel = UILabel(frame: CGRectZero)
    private let dateHeading: UILabel = UILabel(frame: CGRectZero)
    private let dateLabel: UILabel = UILabel(frame: CGRectZero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .None
        
        // Styling for headings
        ipHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        ipHeading.textColor = .EDDBlueColor()
        fileHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        fileHeading.textColor = .EDDBlueColor()
        dateHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        dateHeading.textColor = .EDDBlueColor()
        
        // Text for Headings
        ipHeading.text = NSLocalizedString("IP Address", comment: "")
        fileHeading.text = NSLocalizedString("File", comment: "")
        dateHeading.text = NSLocalizedString("Date", comment: "")
        
        // Styling for labels
        ipLabel.textColor = .EDDBlackColor()
        ipLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        fileLabel.textColor = .EDDBlackColor()
        fileLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        dateLabel.textColor = .EDDBlackColor()
        dateLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func layout() {
        stackView.addArrangedSubview(ipHeading)
        stackView.addArrangedSubview(ipLabel)
        stackView.addArrangedSubview(fileHeading)
        stackView.addArrangedSubview(fileLabel)
        stackView.addArrangedSubview(dateHeading)
        stackView.addArrangedSubview(dateLabel)
        
        containerView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMarginsRelativeArrangement = true
        stackView.alignment = .Top
        
        contentView.addSubview(containerView)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(ipHeading.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(ipLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(ipLabel.bottomAnchor.constraintEqualToAnchor(fileHeading.topAnchor, constant: -20))
        constraints.append(fileHeading.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(fileLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(fileLabel.bottomAnchor.constraintEqualToAnchor(dateHeading.topAnchor, constant: -20))
        constraints.append(dateHeading.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(dateLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
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
    
    func configure(data: [String: AnyObject]) {
        let date = data["date"] as! String
        let dateObject = sharedDateFormatter.dateFromString(date)
        
        if let file: String = data["file"] as? String, let ip: String = data["ip"] as? String {
            fileLabel.text = file
            ipLabel.text = ip
        }
        
        sharedDateFormatter.dateFormat = "EEE dd MMM yyyy HH:mm:ss"
        dateLabel.text = sharedDateFormatter.stringFromDate(dateObject!)
        
        // Reset date format
        sharedDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
}
