//
//  SwitchSiteTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 05/06/2017.
//  Copyright © 2017 Easy Digital Downloads. All rights reserved.
//

import UIKit

final class SwitchSiteTableViewCell: UITableViewCell {

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
    
    let siteNameLabel: UILabel = UILabel(frame: CGRect.zero)
    let siteURLLabel: UILabel = UILabel(frame: CGRect.zero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.isOpaque = true
        isOpaque = true
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        siteNameLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        siteNameLabel.textColor = .white
        
        siteURLLabel.textColor = .white
        siteURLLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        
        layout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Private
    
    fileprivate func layout() {
        containerStackView.addArrangedSubview(siteNameLabel)
        containerStackView.addArrangedSubview(siteURLLabel)
        
        contentView.addSubview(containerStackView)

        var constraints = [NSLayoutConstraint]()
        constraints.append(containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15))
        constraints.append(containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15))
        constraints.append(containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15))
        constraints.append(containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func configure(_ site: Site) {
        siteNameLabel.text = site.name!
        siteURLLabel.text = site.url!
    }

}
