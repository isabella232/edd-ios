//
//  EDDHeaderLabel.m
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 25/12/2015.
//  Copyright © 2015 Easy Digital Downloads. All rights reserved.
//

#import "EDDHeaderLabel.h"

@implementation EDDHeaderLabel

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {10, 5, 10, 5};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
