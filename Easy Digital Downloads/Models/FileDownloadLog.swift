//
//  FileDownloadLog.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 25/08/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import Foundation

class FileDownloadLog: NSObject, NSCoding {
    
    var ID: Int
    var userID: Int
    var productID: Int
    var productName: String
    var customerID: Int
    var paymentID: Int
    var file: String
    var ip: String
    var date: NSDate
    
    init(ID: Int, userID: Int, productID: Int, productName: String, customerID: Int, paymentID: Int, file: String, ip: String, date: NSDate) {
        self.ID = ID
        self.userID = userID
        self.productID = productID
        self.productName = productName
        self.customerID = customerID
        self.paymentID = paymentID
        self.file = file
        self.ip = ip
        self.date = date
    }
    
    required convenience init(coder decoder: NSCoder) {
        let ID = decoder.decodeIntegerForKey("ID")
        let userID = decoder.decodeIntegerForKey("userID")
        let productID = decoder.decodeIntegerForKey("productID")
        let productName = decoder.decodeObjectForKey("productName") as! String
        let customerID = decoder.decodeIntegerForKey("customerID")
        let paymentID = decoder.decodeIntegerForKey("paymentID")
        let file = decoder.decodeObjectForKey("file") as! String
        let ip = decoder.decodeObjectForKey("ip") as! String
        let date = decoder.decodeObjectForKey("date") as! NSDate
        
        self.init(ID: ID, userID: userID, productID: productID, productName: productName, customerID: customerID, paymentID: paymentID, file: file, ip: ip, date: date)
        
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeInt(Int32(self.ID), forKey: "ID")
        coder.encodeInt(Int32(self.userID), forKey: "userID")
        coder.encodeInt(Int32(self.productID), forKey: "productID")
        coder.encodeObject(self.productName, forKey: "productName")
        coder.encodeInt(Int32(self.customerID), forKey: "customerID")
        coder.encodeInt(Int32(self.paymentID), forKey: "paymentID")
        coder.encodeObject(self.file, forKey: "file")
        coder.encodeObject(self.ip, forKey: "IP")
        coder.encodeObject(self.date, forKey: "date")
    }

}
