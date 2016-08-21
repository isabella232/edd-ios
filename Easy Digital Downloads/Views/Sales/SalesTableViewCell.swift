//
//  SalesTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 21/08/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

class SalesTableViewCell: UITableViewCell {

}

extension SalesTableViewCell: ConfigurableCell {
    func configureForObject(object: Sale) {
        print(object)
    }
}