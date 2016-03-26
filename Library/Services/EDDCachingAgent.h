//
//  EDDCachingAgent.h
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 03/01/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, EDDCacheType)
{
    EDDStatsCache,
    EDDSalesCache,
    EDDEarningsCache,
    EDDCommissionsCache,
    EDDReviewsCache,
    EDDAll
};

@interface EDDCachingAgent : NSObject

+ (instancetype)sharedInstance;

- (void)setCacheForSite:(NSInteger)siteID forCacheType:(EDDCacheType)type data:(NSDictionary *)cachedData;
- (NSDictionary *)fetchCacheForSite:(NSInteger)siteID forCacheType:(EDDCacheType)type;
- (void)saveCacheForSite:(NSInteger)siteID forCacheType:(EDDCacheType)type;
- (BOOL)cacheExistsForSite:(NSInteger)siteID forCacheType:(EDDCacheType)type;

@end