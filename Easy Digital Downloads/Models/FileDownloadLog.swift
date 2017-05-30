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
    var date: Date
    
    init(ID: Int, userID: Int, productID: Int, productName: String, customerID: Int, paymentID: Int, file: String, ip: String, date: Date) {
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
        let ID = decoder.decodeInteger(forKey: "ID")
        let userID = decoder.decodeInteger(forKey: "userID")
        let productID = decoder.decodeInteger(forKey: "productID")
        let productName = decoder.decodeObject(forKey: "productName") as! String
        let customerID = decoder.decodeInteger(forKey: "customerID")
        let paymentID = decoder.decodeInteger(forKey: "paymentID")
        let file = decoder.decodeObject(forKey: "file") as! String
        let ip = decoder.decodeObject(forKey: "ip") as! String
        let date = decoder.decodeObject(forKey: "date") as! Date
        
        self.init(ID: ID, userID: userID, productID: productID, productName: productName, customerID: customerID, paymentID: paymentID, file: file, ip: ip, date: date)
        
    }
    
    func encode(with coder: NSCoder) {
        coder.encodeCInt(Int32(self.ID), forKey: "ID")
        coder.encodeCInt(Int32(self.userID), forKey: "userID")
        coder.encodeCInt(Int32(self.productID), forKey: "productID")
        coder.encode(self.productName, forKey: "productName")
        coder.encodeCInt(Int32(self.customerID), forKey: "customerID")
        coder.encodeCInt(Int32(self.paymentID), forKey: "paymentID")
        coder.encode(self.file, forKey: "file")
        coder.encode(self.ip, forKey: "IP")
        coder.encode(self.date, forKey: "date")
    }

}
