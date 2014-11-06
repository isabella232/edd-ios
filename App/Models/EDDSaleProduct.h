//
//  EDDSaleProduct.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/8/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EDDSaleProduct : NSObject

@property (readonly) NSString *name;
@property (readonly) float price;
@property (readonly) NSString *priceName;
@property (readonly) int quantity;

- (id)initWithAttributes:(NSDictionary *)attributes;

- (NSString *)displayName;

@end
