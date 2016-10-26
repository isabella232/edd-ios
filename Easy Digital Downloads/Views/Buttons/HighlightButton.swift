//
//  HighlightButton.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 29/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

class HighlightButton: UIButton {

    override var highlighted: Bool {
        didSet {
            UIView.animateWithDuration(0.2) { 
                self.imageView?.alpha = self.highlighted ? 0.3 : 1
            }
        }
    }

}
