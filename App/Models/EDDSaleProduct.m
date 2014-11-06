//
//  EDDSaleProduct.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/8/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "EDDSaleProduct.h"

#import "NSString+DateHelper.h"

@implementation EDDSaleProduct

@synthesize name = _name;
@synthesize price = _price;
@synthesize priceName = _priceName;

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _name = [attributes valueForKeyPath:@"name"];
    _price = [[attributes valueForKeyPath:@"price"] floatValue];
    _priceName = [attributes valueForKeyPath:@"price_name"];
	_quantity = [[attributes valueForKeyPath:@"quantity"] intValue];
    
    return self;
}

- (NSString *)displayName {
	NSString *name = [NSString stringWithFormat:@"%@", _name];
	
	if (![NSString isNullOrWhiteSpace:_priceName]) {
		name = [NSString stringWithFormat:@"%@ - %@", name, _priceName];
	}
	
	if (_quantity > 1) {
		name = [NSString stringWithFormat:@"%@ (%i)", name, _quantity];
	}
	
	return name;
}

@end
