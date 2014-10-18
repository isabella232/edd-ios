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

@property (readonly) NSUInteger wordpressID;

@property (readonly) NSString *userName;

@property (readonly) NSString *displayName;

@property (readonly) NSString *firstName;

@property (readonly) NSString *lastName;

@property (readonly) NSString *email;

@property (readonly) NSInteger totalPurchases;

@property (readonly) float totalSpent;

@property (readonly) NSInteger totalDownloads;

- (id)initWithAttributes:(NSDictionary *)attributes;

+ (void)globalCustomersWithPage:(NSInteger)page andWithBlock:(void (^)(NSArray *customers, NSError *error))block;

@end
