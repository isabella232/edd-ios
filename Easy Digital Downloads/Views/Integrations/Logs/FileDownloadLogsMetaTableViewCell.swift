//
//  FileDownloadLogsMetaTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 28/08/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import SwiftyJSON

private let sharedDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "EEE dd MMM yyyy HH:mm:ss"
    return formatter
}()

class FileDownloadLogsMetaTableViewCell: UITableViewCell {
    
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
    
    fileprivate let ipHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let ipLabel: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let fileHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let fileLabel: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let dateHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let dateLabel: UILabel = UILabel(frame: CGRect.zero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        
        // Styling for headings
        ipHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        ipHeading.textColor = .EDDBlueColor()
        fileHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        fileHeading.textColor = .EDDBlueColor()
        dateHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        dateHeading.textColor = .EDDBlueColor()
        
        // Text for Headings
        ipHeading.text = NSLocalizedString("IP Address", comment: "")
        fileHeading.text = NSLocalizedString("File", comment: "")
        dateHeading.text = NSLocalizedString("Date", comment: "")
        
        // Styling for labels
        ipLabel.textColor = .EDDBlackColor()
        ipLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        fileLabel.textColor = .EDDBlackColor()
        fileLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        dateLabel.textColor = .EDDBlackColor()
        dateLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
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
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.alignment = .top
        
        contentView.addSubview(containerView)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(ipHeading.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(ipLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(ipLabel.bottomAnchor.constraint(equalTo: fileHeading.topAnchor, constant: -20))
        constraints.append(fileHeading.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(fileLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(fileLabel.bottomAnchor.constraint(equalTo: dateHeading.topAnchor, constant: -20))
        constraints.append(dateHeading.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(dateLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
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
    
    func configure(_ log: Log) {
        fileLabel.text = log.file
        ipLabel.text = log.ip
        
        dateLabel.text = sharedDateFormatter.string(from: log.date as Date)
    }
    
}
