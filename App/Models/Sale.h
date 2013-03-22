//
//  Sale.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/8/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EDDAPIClient.h"

@interface Sale : NSObject

@property (readonly) NSUInteger saleID;
@property (readonly) float subtotal;
@property (readonly) float tax;
@property (readonly) NSArray *fees;
@property (readonly) float total;
@property (readonly) NSString *gateway;
@property (readonly) NSString *email;
@property (readonly) NSDate *date;
@property (readonly) NSArray *products;

- (id)initWithAttributes:(NSDictionary *)attributes;

+ (void)globalSalesWithPage:(int)page andWithBlock:(void (^)(NSArray *sales, NSError *error))block;

@end
