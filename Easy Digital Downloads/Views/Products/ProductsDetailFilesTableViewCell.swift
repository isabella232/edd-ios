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
        return view
    }()
    
    public let filesLabel = UITextView(frame: CGRect.zero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        filesLabel.translatesAutoresizingMaskIntoConstraints = false
        filesLabel.isScrollEnabled = false
        filesLabel.isEditable = false
        
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(_ files: Data) {
        let filesArray: [AnyObject] = NSKeyedUnarchiver.unarchiveObject(with: files)! as! [AnyObject]
        
        let filesString = NSMutableAttributedString()
        var finalString = NSAttributedString()
        
        for file in filesArray {
            let headingAttributes: [String: AnyObject] = [
                NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline),
                NSForegroundColorAttributeName: UIColor.EDDBlueColor()
            ]
            
            let textAttributes: [String: AnyObject] = [
                NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline),
                NSForegroundColorAttributeName: UIColor.EDDBlackColor(),
            ]
            
            let fileNameString = NSAttributedString(string: file["name"] as! String + "\n", attributes: headingAttributes)
            filesString.append(fileNameString)
            
            let plainString = "Condition: " + (file["condition"] as! String).capitalized + "\n" + "URL: " + (file["file"] as! String) + "\n\n"
            
            let range = (plainString as NSString).range(of: file["file"] as! String)
            
            let fileDetailsString = NSMutableAttributedString(string: plainString, attributes: textAttributes)
            fileDetailsString.addAttributes([NSLinkAttributeName: NSURL(string: file["file"] as! String)!], range: range)
            filesString.append(fileDetailsString)
        }
        
        finalString = filesString.attributedSubstring(from: NSMakeRange(0, filesString.length - 2))
        
        filesLabel.attributedText = finalString
        
        stackView.addArrangedSubview(filesLabel)
        
        containerView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.alignment = .top
        
        contentView.addSubview(containerView)
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10))
        constraints.append(containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10))
        constraints.append(containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10))
        constraints.append(containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10))
        constraints.append(stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10))
        constraints.append(stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10))
        constraints.append(stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10))
        constraints.append(stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10))
        
        NSLayoutConstraint.activate(constraints)
    }

}
