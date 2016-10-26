//
//  LoginSubmitButton.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 25/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

class LoginSubmitButton: UIButton {

    var isAnimating: Bool {
        get {
            return activityIndicator.isAnimating()
        }
    }
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override var highlighted: Bool {
        didSet {
            if (highlighted) {
                backgroundColor = .EDDBlueHighlightColor()
            } else {
                backgroundColor = .EDDBlueColor()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(frame: CGRectMake(0, 0, 0, 0))
        addSubview(activityIndicator)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if activityIndicator.isAnimating() {
            titleLabel?.frame = CGRectZero
            
            var frm = activityIndicator.frame
            frm.origin.x = (frame.width - frm.width) / 2.0
            frm.origin.y = (frame.height - frm.height) / 2.0
            activityIndicator.frame = frm
        }
    }
    
    func showActivityIndicator(show: Bool) {
        if show {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        setNeedsLayout()
    }

}
