//
//  SaleFee.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/17/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "SaleFee.h"

@implementation SaleFee

@synthesize name = _name;
@synthesize cost = _cost;

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
	
    _name = [attributes valueForKeyPath:@"label"];
	_cost = [[attributes valueForKeyPath:@"amount"] floatValue];
	
	return self;
}

@end
