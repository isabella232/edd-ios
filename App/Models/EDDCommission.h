//
//  EDDCommission.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 2/24/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EDDAPIClient.h"

@interface EDDCommission : NSObject

@property (readonly) float amount;
@property (readonly) float rate;
@property (readonly) NSString *currency;
@property (readonly) NSString *item;
@property (readonly) NSString *status;
@property (readonly) NSString *date;

- (id)initWithAttributes:(NSDictionary *)attributes;

+ (void)globalCommissionsWithBlock:(void (^)(NSArray *unpaid, NSArray *paid, float unpaidTotal, float paidTotal, NSError *error))block;

+ (void)globalStoreCommissions:(NSInteger)page block:(void (^)(NSArray *commissions, float totalUnpaid, NSError *error))block;

@end
