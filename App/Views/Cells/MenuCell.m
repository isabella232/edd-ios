//
//  MenuCell.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/9/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "MenuCell.h"

#import "UIColor+Helpers.h"

@implementation MenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	[super setHighlighted:highlighted animated:animated];
	
	if (highlighted) {
		self.label.shadowColor = [UIColor clearColor];
	} else {
		self.label.shadowColor = [UIColor blackColor];
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
	
	if (selected) {
		self.label.shadowColor = [UIColor clearColor];
	} else {
		self.label.shadowColor = [UIColor blackColor];
	}
}

@end
