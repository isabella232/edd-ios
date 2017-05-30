//
//  SalesFilterDatePickerTableViewCell.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 03/10/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

protocol UpdateDateCellDelegate {
    func sendDate(_ date: Date, tag: Int)
}

class SalesFilterDatePickerTableViewCell: UITableViewCell, UIPickerViewDelegate {

    var delegate: UpdateDateCellDelegate?
    
    var datePicker: UIDatePicker!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.isOpaque = true
        isOpaque = true
        
        datePicker = UIDatePicker(frame: CGRect.zero)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.backgroundColor = .clear
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(SalesFilterDatePickerTableViewCell.onDidChangeDate(_:)), for: .valueChanged)
        datePicker.maximumDate = Date()
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func layout() {
        contentView.addSubview(datePicker)
        
        var constraints = [NSLayoutConstraint]()

        constraints.append(datePicker.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0))
        constraints.append(datePicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0))
        constraints.append(NSLayoutConstraint(item: datePicker, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: CGFloat(1), constant: 0))
        constraints.append(NSLayoutConstraint(item: datePicker, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: CGFloat(1), constant: 0))
        constraints.append(NSLayoutConstraint(item: datePicker, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: CGFloat(1), constant: CGFloat(0)))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    internal func onDidChangeDate(_ sender: UIDatePicker) {
        DispatchQueue.main.async(execute: {
            self.delegate?.sendDate(sender.date, tag: self.tag)
        })
    }

}
