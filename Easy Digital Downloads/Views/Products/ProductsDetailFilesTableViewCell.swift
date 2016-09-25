//
//  ProductsDetailFilesTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 25/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

class ProductsDetailFilesTableViewCell: UITableViewCell {

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
        return view
    }()
    
    private let filesLabel = UILabel(frame: CGRectZero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        filesLabel.lineBreakMode = .ByWordWrapping
        filesLabel.numberOfLines = 0
        
        selectionStyle = .None
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(files: NSData) {
        let filesArray: [AnyObject] = NSKeyedUnarchiver.unarchiveObjectWithData(files)! as! [AnyObject]
        
        let filesString = NSMutableAttributedString()
        var finalString = NSAttributedString()
        
        for file in filesArray {
            let headingAttributes: [String: AnyObject] = [
                NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline),
                NSForegroundColorAttributeName: UIColor.EDDBlueColor()
            ]
            
            let textAttributes: [String: AnyObject] = [
                NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline),
                NSForegroundColorAttributeName: UIColor.EDDBlackColor()
            ]
            
            let fileNameString = NSAttributedString(string: file["name"] as! String + "\n", attributes: headingAttributes)
            filesString.appendAttributedString(fileNameString)
            
            let fileDetailsString = NSAttributedString(string: "Condition: " + (file["condition"] as! String).capitalizedString + "\n" + "URL: " + (file["file"] as! String) + "\n\n", attributes: textAttributes)
            filesString.appendAttributedString(fileDetailsString)
        }
        
        finalString = filesString.attributedSubstringFromRange(NSMakeRange(0, filesString.length - 2))
        
        filesLabel.attributedText = finalString
        
        stackView.addArrangedSubview(filesLabel)
        
        containerView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMarginsRelativeArrangement = true
        stackView.alignment = .Top
        
        contentView.addSubview(containerView)
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(containerView.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 10))
        constraints.append(containerView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor, constant: -10))
        constraints.append(containerView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 10))
        constraints.append(containerView.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor, constant: -10))
        constraints.append(stackView.topAnchor.constraintEqualToAnchor(containerView.topAnchor, constant: 10))
        constraints.append(stackView.bottomAnchor.constraintEqualToAnchor(containerView.bottomAnchor, constant: -10))
        constraints.append(stackView.leadingAnchor.constraintEqualToAnchor(containerView.leadingAnchor, constant: 10))
        constraints.append(stackView.trailingAnchor.constraintEqualToAnchor(containerView.trailingAnchor, constant: -10))
        
        NSLayoutConstraint.activateConstraints(constraints)
    }

}
