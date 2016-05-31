//
//  ConfigurableCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 29/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import Foundation

protocol ConfigurableCell {

    associatedtype DataSource
    func configureForObject(object: DataSource)

}