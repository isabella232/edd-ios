//
//  CustomerProfileTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 20/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

private let sharedDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    formatter.dateFormat = "d MMM yyyy"
    return formatter
}()

class CustomerProfileTableViewCell: UITableViewCell {

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
    
    private var profileImageView: UIImageView = UIImageView(frame: CGRectZero)
    private let nameLabel = UILabel(frame: CGRectZero)
    private let emailLabel = UILabel(frame: CGRectZero)
    private var gravatar: Gravatar?
    private var customer: Customer?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        profileImageView = {
            let imageView = UIImageView(frame: CGRectZero)
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .ScaleAspectFit
            imageView.clipsToBounds = true
            
            return imageView
        }()
        
        nameLabel.textColor = .EDDBlackColor()
        nameLabel.font = UIFont.systemFontOfSize(16, weight: UIFontWeightMedium)
        nameLabel.textAlignment = .Center
        
        emailLabel.textColor = .EDDBlackColor()
        emailLabel.font = UIFont.systemFontOfSize(14, weight: UIFontWeightRegular)
        emailLabel.textAlignment = .Center
        emailLabel.lineBreakMode = .ByWordWrapping
        emailLabel.numberOfLines = 0
        
        selectionStyle = .None
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        profileImageView.af_cancelImageRequest()
        profileImageView.layer.removeAllAnimations()
        profileImageView.image = nil
    }
    
    private func setupImageView() {
        guard let customer_ = customer else {
            return
        }
        
        gravatar = Gravatar(emailAddress: customer_.email)
        let url = gravatar?.URL(CGFloat(60))
        
        profileImageView.af_setImageWithURL(url!, placeholderImage: nil, filter: AspectScaledToFillSizeWithRoundedCornersFilter(size: CGSizeMake(60, 60), radius: 30), progress: nil, progressQueue: dispatch_get_main_queue(), imageTransition: .CrossDissolve(0.2), runImageTransitionIfCached: true, completion: nil)
    }
    
    func configure(customer: Customer) {
        self.customer = customer
        
        nameLabel.text = customer.displayName
        emailLabel.text = customer.email.lowercaseString + "\n" + "Customer since " + sharedDateFormatter.stringFromDate(customer.dateCreated)
        
        setupImageView()
        layout()
    }

    func layout() {
        stackView.addArrangedSubview(profileImageView)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(emailLabel)
        
        containerView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMarginsRelativeArrangement = true
        stackView.alignment = .Top
        
        contentView.addSubview(containerView)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(nameLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(emailLabel.widthAnchor.constraintEqualToAnchor(stackView.widthAnchor, multiplier: 1.0))
        constraints.append(profileImageView.widthAnchor.constraintEqualToConstant(60))
        constraints.append(profileImageView.heightAnchor.constraintEqualToConstant(60))
        constraints.append(profileImageView.centerXAnchor.constraintEqualToAnchor(contentView.centerXAnchor))
        constraints.append(containerView.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 0))
        constraints.append(containerView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor, constant: 0))
        constraints.append(containerView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 0))
        constraints.append(containerView.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor, constant: 0))
        constraints.append(stackView.topAnchor.constraintEqualToAnchor(containerView.topAnchor, constant: 15))
        constraints.append(stackView.bottomAnchor.constraintEqualToAnchor(containerView.bottomAnchor, constant: -15))
        constraints.append(stackView.leadingAnchor.constraintEqualToAnchor(containerView.leadingAnchor, constant: 0))
        constraints.append(stackView.trailingAnchor.constraintEqualToAnchor(containerView.trailingAnchor, constant: 0))
        
        NSLayoutConstraint.activateConstraints(constraints)
    }
    
}
