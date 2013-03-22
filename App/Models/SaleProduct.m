//
//  Product.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/8/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "SaleProduct.h"

@implementation SaleProduct

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
    
    return self;
}

@end
