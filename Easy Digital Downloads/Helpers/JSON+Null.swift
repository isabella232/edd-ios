//
//  JSON+Null.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 21/08/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import Foundation
import SwiftyJSON

extension JSON {
    public var isNull: Bool {
        get {
            return self.type == .Null;
        }
    }
}