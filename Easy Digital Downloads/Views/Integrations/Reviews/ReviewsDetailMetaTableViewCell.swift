//
//  ReviewsDetailMetaTableViewCell.swift
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
    formatter.dateFormat = "EEE dd MMM yyyy HH:mm:ss"
    return formatter
}()

class ReviewsDetailMetaTableViewCell: UITableViewCell {

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
    
    fileprivate let authorHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let authorLabel: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let ratingHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let ratingLabel: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let dateHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let dateLabel: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let typeHeading: UILabel = UILabel(frame: CGRect.zero)
    fileprivate let typeLabel: UILabel = UILabel(frame: CGRect.zero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        // Styling for headings
        authorHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        authorHeading.textColor = .EDDBlueColor()
        ratingHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        ratingHeading.textColor = .EDDBlueColor()
        dateHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        dateHeading.textColor = .EDDBlueColor()
        typeHeading.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        typeHeading.textColor = .EDDBlueColor()
        
        // Text for Headings
        authorHeading.text = NSLocalizedString("Author", comment: "")
        ratingHeading.text = NSLocalizedString("Rating", comment: "")
        dateHeading.text = NSLocalizedString("Date", comment: "")
        typeHeading.text = NSLocalizedString("Type", comment: "")
        
        // Styling for labels
        authorLabel.textColor = .EDDBlackColor()
        authorLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        ratingLabel.textColor = .EDDBlackColor()
        ratingLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        dateLabel.textColor = .EDDBlackColor()
        dateLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        typeLabel.textColor = .EDDBlackColor()
        typeLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
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
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.alignment = .top
        
        contentView.addSubview(containerView)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(authorHeading.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(authorLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(authorLabel.bottomAnchor.constraint(equalTo: ratingHeading.topAnchor, constant: -20))
        constraints.append(ratingHeading.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(ratingLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(ratingLabel.bottomAnchor.constraint(equalTo: dateHeading.topAnchor, constant: -20))
        constraints.append(dateHeading.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(dateLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(dateLabel.bottomAnchor.constraint(equalTo: typeHeading.topAnchor, constant: -20))
        constraints.append(typeHeading.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(typeLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
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
    
    func configure(_ review: Review) {
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
        typeLabel.text = review.type.capitalized
        
        dateLabel.text = sharedDateFormatter.string(from: review.date as Date)
        
        layout()
    }

}
