//
//  ViewControllerTitleLabel.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 03/10/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

class ViewControllerTitleLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clearColor()
        numberOfLines = 0
        textAlignment = .Center
        lineBreakMode = .ByWordWrapping
    }
    
    func setTitle(title: String) {
        guard let siteName = Site.activeSite().name else {
            return
        }
        
        let titleString = NSMutableAttributedString()
        
        let headingAttributes: [String: AnyObject] = [
            NSFontAttributeName: UIFont.systemFontOfSize(13, weight: UIFontWeightLight),
            NSForegroundColorAttributeName: UIColor.colorWithHex(0xffffff, alpha: 0.8)
        ]
        
        let textAttributes: [String: AnyObject] = [
            NSFontAttributeName: UIFont.systemFontOfSize(17, weight: UIFontWeightMedium),
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        
        let siteNameAttributedString = NSAttributedString(string: siteName + "\n", attributes: headingAttributes)
        titleString.appendAttributedString(siteNameAttributedString)

        let titleAttributedString = NSAttributedString(string: title, attributes: textAttributes)
        titleString.appendAttributedString(titleAttributedString)
        
        attributedText = titleString
        
        sizeToFit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
