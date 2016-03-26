//
//  EDDighlightButton.m
//  Phuse
//
//  Created by Sunny Ratilal on 30/12/2015.
//  Copyright (c) 2015 Sunny Ratilal. All rights reserved.
//

#import "EDDHighlightButton.h"

@implementation EDDHighlightButton

- (void)setHighlighted:(BOOL)highlighted{
    [UIView animateWithDuration:0.2f animations:^(){
        self.imageView.alpha = highlighted ? 0.3 : 1.0;
    }];
}

@end
