//
//  ReviewsDetailMetaTableViewCell.swift
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
    formatter.dateFormat = "EEE dd MMM yyyy HH:mm:ss"
    return formatter
}()

class ReviewsDetailMetaTableViewCell: UITableViewCell {

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
    
    private let authorHeading: UILabel = UILabel(frame: CGRectZero)
    private let authorLabel: UILabel = UILabel(frame: CGRectZero)
    private let ratingHeading: UILabel = UILabel(frame: CGRectZero)
    private let ratingLabel: UILabel = UILabel(frame: CGRectZero)
    private let dateHeading: UILabel = UILabel(frame: CGRectZero)
    private let dateLabel: UILabel = UILabel(frame: CGRectZero)
    private let typeHeading: UILabel = UILabel(frame: CGRectZero)
    private let typeLabel: UILabel = UILabel(frame: CGRectZero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .None
        
        // Styling for headings
        authorHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        authorHeading.textColor = .EDDBlueColor()
        ratingHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        ratingHeading.textColor = .EDDBlueColor()
        dateHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        dateHeading.textColor = .EDDBlueColor()
        typeHeading.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        typeHeading.textColor = .EDDBlueColor()
        
        // Text for Headings
        authorHeading.text = NSLocalizedString("Author", comment: "")
        ratingHeading.text = NSLocalizedString("Rating", comment: "")
        dateHeading.text = NSLocalizedString("Date", comment: "")
        typeHeading.text = NSLocalizedString("Type", comment: "")
        
        // Styling for labels
        authorLabel.textColor = .EDDBlackColor()
        authorLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        ratingLabel.textColor = .EDDBlackColor()
        ratingLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        dateLabel.textColor = .EDDBlackColor()
        dateLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        typeLabel.textColor = .EDDBlackColor()
        typeLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func layout() {
        stackView.addArrangedSubview(authorHeading)
        stackView.addArrangedSubview(authorLabel)
        stackView.addArrangedSubview(ratingHeading)
        stackView.addArrangedSubview(ratingLabel)
        stackView.addArrangedSubview(dateHeading)
        stackView.addArrangedSubview(dateLabel)
        stackView.addArrangedSubview(typeHeading)
        stackView.addArrangedSubview(typeLabel)
        
        containerView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMarginsRelativeArrangement = true
        stackView.alignment = .Top
        
        contentView.addSubview(containerView)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(authorHeading.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(authorLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(authorLabel.bottomAnchor.constraintEqualToAnchor(ratingHeading.topAnchor, constant: -20))
        constraints.append(ratingHeading.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(ratingLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(ratingLabel.bottomAnchor.constraintEqualToAnchor(dateHeading.topAnchor, constant: -20))
        constraints.append(dateHeading.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(dateLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(dateLabel.bottomAnchor.constraintEqualToAnchor(typeHeading.topAnchor, constant: -20))
        constraints.append(typeHeading.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(typeLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
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
    
    func configure(review: Review) {
        var stars = ""
        
        if review.rating == 1 {
            stars = "\u{2605}"
        } else {
            for _ in 0...review.rating {
                stars += "\u{2605}"
            }
        }
        
        ratingLabel.text = stars
        authorLabel.text = review.author
        typeLabel.text = review.type.capitalizedString
        
        dateLabel.text = sharedDateFormatter.stringFromDate(review.date)
        
        layout()
    }

}
