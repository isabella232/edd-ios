//
//  EDDSetupTextField.m
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 26/08/2015.
//  Copyright © 2015 Easy Digital Downloads. All rights reserved.
//

#import "EDDSetupTextField.h"

@implementation EDDSetupTextField

- (instancetype)init
{
    self = [super init];

    if (self) {
        self.textInsets = UIEdgeInsetsMake(7, 10, 7, 10);
        self.layer.cornerRadius = 1.0;
        self.clipsToBounds = YES;
    }

    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectMake(self.textInsets.left, self.textInsets.top, bounds.size.width - self.textInsets.left - self.textInsets.right, bounds.size.height - self.textInsets.top - self.textInsets.bottom);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectMake(self.textInsets.left, self.textInsets.top, bounds.size.width - self.textInsets.left - self.textInsets.right, bounds.size.height - self.textInsets.top - self.textInsets.bottom);
}

@end