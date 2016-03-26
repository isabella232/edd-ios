//
//  EDDLaunchCell.m
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 28/12/2015.
//  Copyright © 2015 Easy Digital Downloads. All rights reserved.
//

#import "EDDLaunchCell.h"

@implementation EDDLaunchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (selected) {
        self.contentView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
    } else {
        self.contentView.backgroundColor = [UIColor clearColor];
    }
}

@end