//
//  String+HTML.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 04/10/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import Foundation
import UIKit

extension String {

    init(htmlEncodedString: String) {
        let encodedData: Data = htmlEncodedString.data(using: String.Encoding.utf8)!
        let attributedOptions : [String: AnyObject] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType as AnyObject,
            NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue as AnyObject
        ]
        
        var attributedString: NSAttributedString?
        
        do {
            attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
        } catch {
            
        }
        
        self.init(attributedString!.string)!
    }

}
