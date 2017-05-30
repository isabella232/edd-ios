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
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        backgroundColor = UIColor.white
        adjustsFontSizeToFitWidth = true
        keyboardAppearance = .dark
        autocorrectionType = .no
        autocapitalizationType = .words
        autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        returnKeyType = .next
        
        imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        imageView.contentMode = .scaleAspectFit
        rightView = imageView
        rightViewMode = .always
        rightView?.isHidden = true
        addSubview(imageView)
    }
    
    func validated(_ valid: Bool) {
        rightView?.isHidden = false

        if valid {
            imageView.tintColor = .validColor()
            imageView.image = UIImage(named: "Checkmark")
        } else {
            imageView.tintColor = .errorColor()
            imageView.image = UIImage(named: "Error")
        }
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        if disableEditing {
            return CGRect.zero
        } else {
            return super.caretRect(for: position)
        }
    }
    
    override func selectionRects(for range: UITextRange) -> [Any] {
        if disableEditing {
            return []
        } else {
            return super.selectionRects(for: range)
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if disableEditing {
            return false
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.size.width - 25, y: 10, width: 20, height: 20)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, textInsets)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, textInsets)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, textInsets)
    }
    
}
