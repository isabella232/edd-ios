//
//  CommissionsStatusLabel.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 02/10/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

class CommissionsStatusLabel: UILabel {

    let padding = UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 5)
    
    override func drawTextInRect(rect: CGRect) {
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, padding))
    }

    override func intrinsicContentSize() -> CGSize {
        let superContentSize = super.intrinsicContentSize()
        let width = superContentSize.width + padding.left + padding.right
        let height = superContentSize.height + padding.top + padding.bottom

        return CGSize(width: width, height: height)
    }


    override func sizeThatFits(size: CGSize) -> CGSize {
        let superSizeThatFits = super.sizeThatFits(size)
        let width = superSizeThatFits.width + padding.left + padding.right
        let height = superSizeThatFits.height + padding.top + padding.bottom

        return CGSize(width: width, height: height)
    }

}
