//
//  EDDUILabel.m
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 26/12/2015.
//  Copyright © 2015 Easy Digital Downloads. All rights reserved.
//

#import "EDDUILabel.h"

@implementation EDDUILabel

- (void)drawTextInRect:(CGRect)rect
{
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(_topInset, _leftInset, _bottomInset, _rightInset))];
}

@end