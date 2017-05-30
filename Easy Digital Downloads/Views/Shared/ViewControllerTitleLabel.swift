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
        
        backgroundColor = .clear
        numberOfLines = 0
        textAlignment = .center
        lineBreakMode = .byWordWrapping
    }
    
    func setTitle(_ title: String) {
        guard let siteName = Site.activeSite().name else {
            return
        }
        
        let titleString = NSMutableAttributedString()
        
        let headingAttributes: [String: AnyObject] = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 13, weight: UIFontWeightLight),
            NSForegroundColorAttributeName: UIColor.colorWithHex(0xffffff, alpha: 0.8)
        ]
        
        let textAttributes: [String: AnyObject] = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 17, weight: UIFontWeightMedium),
            NSForegroundColorAttributeName: UIColor.white
        ]
        
        let siteNameAttributedString = NSAttributedString(string: siteName + "\n", attributes: headingAttributes)
        titleString.append(siteNameAttributedString)

        let titleAttributedString = NSAttributedString(string: title, attributes: textAttributes)
        titleString.append(titleAttributedString)
        
        attributedText = titleString
        
        sizeToFit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
