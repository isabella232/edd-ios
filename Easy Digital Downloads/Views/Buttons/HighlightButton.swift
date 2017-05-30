//
//  HighlightButton.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 29/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

class HighlightButton: UIButton {

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.2, animations: { 
                self.imageView?.alpha = self.isHighlighted ? 0.3 : 1
            }) 
        }
    }

}
