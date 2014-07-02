//
//  EDDSearchBar.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 7/1/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import "EDDSearchBar.h"

@implementation EDDSearchBar

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		[self baseInit];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self baseInit];
	}
	return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	
	[self baseInit];
}

- (void)baseInit {
	self.layer.borderWidth = 1;
	self.layer.borderColor = [[UIColor clearColor] CGColor];
}

@end
