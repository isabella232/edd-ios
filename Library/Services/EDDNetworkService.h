//
//  EDDNetworkService.h
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 25/12/2015.
//  Copyright © 2015 Easy Digital Downloads. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EDDSite.h"

@interface EDDNetworkService : NSObject

@property (nonatomic, strong) EDDSite *site;

+ (id)sharedInstance;

- (void)fetchStats:(void (^)(NSDictionary *stats))completionBlock;
- (void)fetchSales:(NSInteger)page completionBlock:(void (^)(NSDictionary *sales))completionBlock;
- (void)fetchEarnings:(NSInteger)page completionBlock:(void (^)(NSDictionary *earnings))completionBlock;
- (void)fetchCustomers:(NSInteger)page completionBlock:(void (^)(NSDictionary *customers))completionBlock;
- (void)fetchReviews:(NSInteger)page completionBlock:(void (^)(NSDictionary *reviews))completionBlock;
- (void)fetchCommissions:(NSInteger)page completionBlock:(void (^)(NSDictionary *commissions))completionBlock;
- (void)fetchStoreCommissions:(NSInteger)page completionBlock:(void (^)(NSDictionary *storeCommissions))completionBlock;
- (void)fetchGraphData:(NSString *)endpoint completionBlock:(void (^)(NSDictionary *graphData))completionBlock;

@end