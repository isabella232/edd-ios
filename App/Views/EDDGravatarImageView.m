//
//  EDDGravatarImageView.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 10/18/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import "EDDGravatarImageView.h"

@implementation EDDGravatarImageView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setupBorder];
}

- (void)setupBorder {
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 0.2f;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = self.frame.size.width / 2.0f;
}

@end
