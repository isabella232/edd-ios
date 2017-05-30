//
//  GravatarTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 20/09/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import Foundation
import UIKit

private extension String  {
    var md5_hash: String {
        let trimmedString = lowercased().trimmingCharacters(in: CharacterSet.whitespaces)
        let utf8String = trimmedString.cString(using: String.Encoding.utf8)!
        let stringLength = CC_LONG(trimmedString.lengthOfBytes(using: String.Encoding.utf8))
        let digestLength = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLength)
        
        CC_MD5(utf8String, stringLength, result)
        
        var hash = ""
        
        for i in 0..<digestLength {
            hash += String(format: "%02x", result[i])
        }
        
        result.deallocate(capacity: digestLength)
        
        return String(format: hash)
    }
}

// MARK: - QueryItemConvertible

private protocol QueryItemConvertible {
    var queryItem: URLQueryItem {get}
}

// MARK: -

public struct Gravatar {
    public enum DefaultImage: String, QueryItemConvertible {
        case HTTP404 = "404"
        case MysteryMan = "mm"
        case Identicon = "identicon"
        case MonsterID = "monsterid"
        case Wavatar = "wavatar"
        case Retro = "retro"
        case Blank = "blank"
        
        var queryItem: URLQueryItem {
            return URLQueryItem(name: "d", value: rawValue)
        }
    }
    
    public enum Rating: String, QueryItemConvertible {
        case G = "g"
        case PG = "pg"
        case R = "r"
        case X = "x"
        
        var queryItem: URLQueryItem {
            return URLQueryItem(name: "r", value: rawValue)
        }
    }
    
    public let email: String
    public let forceDefault: Bool
    public let defaultImage: DefaultImage
    public let rating: Rating
    
    fileprivate static let baseURL = Foundation.URL(string: "https://www.gravatar.com/avatar/")!
    
    public init(
        emailAddress: String,
        defaultImage: DefaultImage = .MysteryMan,
        forceDefault: Bool = false,
        rating: Rating = .PG)
    {
        self.email = emailAddress
        self.defaultImage = defaultImage
        self.forceDefault = forceDefault
        self.rating = rating
    }
    
    public func URL(_ size: CGFloat, scale: CGFloat = UIScreen.main.scale) -> Foundation.URL {
        #if swift(>=2.3)
            let URL = Gravatar.baseURL.appendingPathComponent(email.md5_hash)
        #else
            let URL = Gravatar.baseURL.URLByAppendingPathComponent(email.md5_hash)
        #endif
        
        var components = URLComponents(url: URL, resolvingAgainstBaseURL: false)!
        
        var queryItems = [defaultImage.queryItem]
        queryItems.append(URLQueryItem(name: "s", value: String(format: "%.0f",size * scale)))
        
        components.queryItems = queryItems
        
        return components.url!
    }
}
