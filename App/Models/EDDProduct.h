//
//  EDDProduct.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/8/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EDDAPIClient.h"

@interface EDDProduct : NSObject

@property (readonly) NSUInteger productID;
@property (readonly) NSString *slug;
@property (readonly) NSString *title;
@property (readonly) NSDate *createdDate;
@property (readonly) NSDate *modifiedDate;
@property (readonly) NSString *status;
@property (readonly) NSString *link;
@property (readonly) NSString *content;
@property (readonly) NSString *thumbnail;
@property (readonly) int totalSales;
@property (readonly) float totalEarnings;
@property (readonly) int monthlySalesAverage;
@property (readonly) float monthlyEarningsAverage;
@property (readonly) float price;
@property (readonly) NSString *notes;

- (id)initWithAttributes:(NSDictionary *)attributes;

+ (void)globalProductsWithPage:(int)page andWithBlock:(void (^)(NSArray *sales, NSError *error))block;

@end