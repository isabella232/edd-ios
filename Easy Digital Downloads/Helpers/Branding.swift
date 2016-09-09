//
//  Branding.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 23/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

extension UIColor {

    class func colorWithHex(hex: Int, alpha: CGFloat = 1.0) -> UIColor {
        let r = CGFloat((hex & 0xff0000) >> 16) / 255.0
        let g = CGFloat((hex & 0x00ff00) >>  8) / 255.0
        let b = CGFloat((hex & 0x0000ff) >>  0) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }
    
    class func EDDBlueColor() -> UIColor {
        return UIColor.colorWithHex(0x2794da)
    }
    
    class func EDDBlueHighlightColor() -> UIColor {
        return UIColor.colorWithHex(0x2386c5)
    }
    
    class func EDDBlackColor() -> UIColor {
        return UIColor.colorWithHex(0x1d2428)
    }
    
    class func EDDBlackHighlightColor() -> UIColor {
        return UIColor.colorWithHex(0x303e4c)
    }
    
    class func EDDGreyColor() -> UIColor {
        return UIColor.colorWithHex(0xf7f7f7)
    }
    
    class func validColor() -> UIColor {
        return UIColor.colorWithHex(0x93c382)
    }
    
    class func errorColor() -> UIColor {
        return UIColor.colorWithHex(0x7c1d2d)
    }
    
    class func separatorColor() -> UIColor {
        return UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
    }
    
    class func tableViewCellHighlightColor() -> UIColor {
        return UIColor.colorWithHex(0xd7e9f3)
    }

}