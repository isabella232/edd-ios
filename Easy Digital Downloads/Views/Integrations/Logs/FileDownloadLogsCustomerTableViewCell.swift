//
//  FileDownloadLogsCustomerTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 28/08/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

class FileDownloadLogsCustomerTableViewCell: UITableViewCell {

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
    
    let nameLabel: UILabel = UILabel(frame: CGRect.zero)
    let emailLabel: UILabel = UILabel(frame: CGRect.zero)
    let disclosureImageView: UIImageView = UIImageView(image: UIImage(named: "DisclosureIndicator"))
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.isOpaque = true
        isOpaque = true
        
        backgroundColor = .white
        contentView.backgroundColor = .white
        
        nameLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        nameLabel.textColor = .EDDBlueColor()
        
        emailLabel.textColor = .EDDBlackColor()
        emailLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        
        activityIndicator.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        activityIndicator.center = contentView.center
        
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Private
    
    fileprivate func layout() {
        containerStackView.addArrangedSubview(nameLabel)
        containerStackView.addArrangedSubview(emailLabel)
        
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

    func configureForObject(_ customer: Customer?) {
        guard let object = customer else {
            activityIndicator.startAnimating()
            contentView.addSubview(activityIndicator)
            return
        }
        
        nameLabel.text = object.displayName
        emailLabel.text = object.email.lowercased()
    }

}
