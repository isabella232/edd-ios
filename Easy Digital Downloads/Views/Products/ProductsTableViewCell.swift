//
//  ProductsTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 01/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

class ProductsTableViewCell: UITableViewCell {
    
    
    
}

extension ProductsTableViewCell: ConfigurableCell {
    
    func configureForObject(object: Sale) {
        print(object.sid)
    }
    
}