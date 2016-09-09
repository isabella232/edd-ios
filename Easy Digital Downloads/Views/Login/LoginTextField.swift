//
//  LoginTextField.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 24/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

class LoginTextField: UITextField {

    let textInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 25)
    let imageView = UIImageView()
    var disableEditing: Bool = false

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(frame: CGRectMake(0, 0, 0, 0))
        backgroundColor = UIColor.whiteColor()
        adjustsFontSizeToFitWidth = true
        keyboardAppearance = .Dark
        autocorrectionType = .No
        autocapitalizationType = .Words
        autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin]
        returnKeyType = .Next
        
        imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        imageView.contentMode = .ScaleAspectFit
        rightView = imageView
        rightViewMode = .Always
        rightView?.hidden = true
        addSubview(imageView)
    }
    
    func validated(valid: Bool) {
        let iconSize = CGSize(width: 20.0, height: 20.0)

        rightView?.hidden = false

        if valid {
            imageView.tintColor = .validColor()
//            imageView.image = Gridicon.iconOfType(.CheckmarkCircle, withSize: iconSize)
        } else {
            imageView.tintColor = .errorColor()
//            imageView.image = Gridicon.iconOfType(.Cross, withSize: iconSize)
        }
    }
    
    override func caretRectForPosition(position: UITextPosition) -> CGRect {
        if disableEditing {
            return CGRect.zero
        } else {
            return super.caretRectForPosition(position)
        }
    }
    
    override func selectionRectsForRange(range: UITextRange) -> [AnyObject] {
        if disableEditing {
            return []
        } else {
            return super.selectionRectsForRange(range)
        }
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
//        if disableEditing && (action == #selector(NSObject.copy(_:)) || action == #selector(NSObject.selectAll) || action == #selector(NSObject.paste)) {
//            return false
//        }
        
        return super.canPerformAction(action, withSender: sender)
    }
    
    override func rightViewRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectMake(bounds.size.width - 30, 10, 20, 20)
    }
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, textInsets)
    }
    
    override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, textInsets)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, textInsets)
    }
    
}
