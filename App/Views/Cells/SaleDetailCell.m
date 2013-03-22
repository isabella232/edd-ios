//
//  SaleDetailCell.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/19/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "SaleDetailCell.h"

@implementation SaleDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
	[super layoutSubviews];  //The default implementation of the layoutSubviews
	
	
	[self.textLabel sizeToFit];
	
//	CGRect textLabelFrame = self.textLabel.frame;
//	textLabelFrame.size.width = 170.0f;
//	self.textLabel.frame = textLabelFrame;
}

@end
