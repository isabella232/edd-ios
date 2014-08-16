//
//  EDDCustomer.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/9/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EDDCustomer : NSObject

@property (readonly) NSUInteger customerID;
@property (readonly) NSString *userName;
@property (readonly) NSString *displayName;
@property (readonly) NSString *firstName;
@property (readonly) NSString *lastName;
@property (readonly) NSString *email;
@property (readonly) int totalPurchases;
@property (readonly) float totalSpent;
@property (readonly) int totalDownloads;

- (id)initWithAttributes:(NSDictionary *)attributes;

+ (void)globalCustomersWithBlock:(void (^)(NSArray *customers, NSError *error))block;

@end
