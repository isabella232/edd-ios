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

private let sharedDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "d MMM yyyy"
    return formatter
}()

class CustomerProfileTableViewCell: UITableViewCell {

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
    
    fileprivate var profileImageView: UIImageView = UIImageView(frame: CGRect.zero)
    fileprivate let nameLabel = UILabel(frame: CGRect.zero)
    fileprivate let emailLabel = UILabel(frame: CGRect.zero)
    fileprivate var gravatar: Gravatar?
    fileprivate var customer: Customer?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        profileImageView = {
            let imageView = UIImageView(frame: CGRect.zero)
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            
            return imageView
        }()
        
        nameLabel.textColor = .EDDBlackColor()
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium)
        nameLabel.textAlignment = .center
        
        emailLabel.textColor = .EDDBlackColor()
        emailLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)
        emailLabel.textAlignment = .center
        emailLabel.lineBreakMode = .byWordWrapping
        emailLabel.numberOfLines = 0
        
        selectionStyle = .none
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
    
    fileprivate func setupImageView() {
        guard let customer_ = customer else {
            return
        }
        
        gravatar = Gravatar(emailAddress: customer_.email)
        let url = gravatar?.URL(CGFloat(60))
        
        print(url);
        
        profileImageView.af_setImageWithURL(url!, placeholderImage: nil, filter: AspectScaledToFillSizeWithRoundedCornersFilter(size: CGSize(width: 60, height: 60), radius: 30), progress: nil, progressQueue: DispatchQueue.main, imageTransition: .CrossDissolve(0.2), runImageTransitionIfCached: true, completion: nil)
    }
    
    func configure(_ customer: Customer) {
        self.customer = customer
        
        nameLabel.text = customer.displayName
        emailLabel.text = customer.email.lowercased() + "\n" + "Customer since " + sharedDateFormatter.string(from: customer.dateCreated as Date)
        
        setupImageView()
        layout()
    }

    func layout() {
        stackView.addArrangedSubview(profileImageView)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(emailLabel)
        
        containerView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.alignment = .top
        
        contentView.addSubview(containerView)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(nameLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(emailLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0))
        constraints.append(profileImageView.widthAnchor.constraint(equalToConstant: 60))
        constraints.append(profileImageView.heightAnchor.constraint(equalToConstant: 60))
        constraints.append(profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor))
        constraints.append(containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0))
        constraints.append(containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0))
        constraints.append(containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0))
        constraints.append(containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0))
        constraints.append(stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15))
        constraints.append(stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15))
        constraints.append(stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0))
        constraints.append(stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0))
        
        NSLayoutConstraint.activate(constraints)
    }
    
}
