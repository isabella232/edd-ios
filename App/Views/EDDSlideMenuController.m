//
//  EDDSlideMenuController.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 6/30/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import "EDDSlideMenuController.h"

@implementation EDDSlideMenuController

- (id)initWithMenuViewController:(UIViewController *)menuViewController andContentViewController:(UIViewController *)contentViewController {
	if (self = [super initWithMenuViewController:menuViewController andContentViewController:contentViewController]) {
		self.menuWidth = 232.0f;
		self.panGestureEnabled = YES;
	}
	return self;
}

@end
