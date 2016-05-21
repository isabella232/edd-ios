//
//  EDDSale.m
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 01/01/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

#import "EDDSale.h"

@implementation EDDSale

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.saleID = [aDecoder decodeIntegerForKey:@"saleID"];
        self.transactionID = [aDecoder decodeObjectForKey:@"transactionID"];
        self.key = [aDecoder decodeObjectForKey:@"key"];
        self.hasDiscount = [aDecoder decodeBoolForKey:@"hasDiscount"];
        self.discount = [aDecoder decodeObjectForKey:@"discount"];
        self.subtotal = [aDecoder decodeDoubleForKey:@"subtotal"];
        self.tax = [aDecoder decodeDoubleForKey:@"tax"];
        self.hasFees = [aDecoder decodeBoolForKey:@"hasFees"];
        self.fees = [aDecoder decodeObjectForKey:@"fees"];
        self.gateway = [aDecoder decodeObjectForKey:@"gateway"];
        self.email = [aDecoder decodeObjectForKey:@"email"];
        self.date = [aDecoder decodeObjectForKey:@"date"];
        self.products = [aDecoder decodeObjectForKey:@"products"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.saleID forKey:@"saleID"];
    [aCoder encodeObject:self.transactionID forKey:@"transactionID"];
    [aCoder encodeObject:self.key forKey:@"key"];
    [aCoder encodeBool:self.hasDiscount forKey:@"hasDiscount"];
    [aCoder encodeObject:self.discount forKey:@"discount"];
    [aCoder encodeDouble:self.subtotal forKey:@"subtotal"];
    [aCoder encodeDouble:self.tax forKey:@"tax"];
    [aCoder encodeBool:self.hasFees forKey:@"hasFees"];
    [aCoder encodeObject:self.fees forKey:@"fees"];
    [aCoder encodeObject:self.gateway forKey:@"gateway"];
    [aCoder encodeObject:self.email forKey:@"email"];
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeObject:self.products forKey:@"products"];
}

@end