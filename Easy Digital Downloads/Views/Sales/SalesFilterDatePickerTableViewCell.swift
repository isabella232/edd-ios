//
//  SalesFilterDatePickerTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 03/10/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

protocol UpdateDateCellDelegate {
    func sendDate(date: NSDate, tag: Int)
}

class SalesFilterDatePickerTableViewCell: UITableViewCell, UIPickerViewDelegate {

    var delegate: UpdateDateCellDelegate?
    
    var datePicker: UIDatePicker!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
        layer.opaque = true
        opaque = true
        
        datePicker = UIDatePicker(frame: CGRectZero)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.backgroundColor = .clearColor()
        datePicker.datePickerMode = .Date
        datePicker.addTarget(self, action: #selector(SalesFilterDatePickerTableViewCell.onDidChangeDate(_:)), forControlEvents: .ValueChanged)
        
        backgroundColor = .clearColor()
        contentView.backgroundColor = .clearColor()
        
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func layout() {
        contentView.addSubview(datePicker)
        
        var constraints = [NSLayoutConstraint]()

        constraints.append(datePicker.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 0))
        constraints.append(datePicker.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor, constant: 0))
        constraints.append(NSLayoutConstraint(item: datePicker, attribute: .Leading, relatedBy: .Equal, toItem: contentView, attribute: .Leading, multiplier: CGFloat(1), constant: 0))
        constraints.append(NSLayoutConstraint(item: datePicker, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .Trailing, multiplier: CGFloat(1), constant: 0))
        constraints.append(NSLayoutConstraint(item: datePicker, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: CGFloat(1), constant: CGFloat(0)))
        
        NSLayoutConstraint.activateConstraints(constraints)
    }
    
    internal func onDidChangeDate(sender: UIDatePicker) {
        dispatch_async(dispatch_get_main_queue(), {
            self.delegate?.sendDate(sender.date, tag: self.tag)
        })
    }

}
