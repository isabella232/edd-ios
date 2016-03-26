//
//  EDDCachingAgent.m
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 03/01/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

#import "EDDCachingAgent.h"

@interface EDDCachingAgent ()

@property (nonatomic, strong) NSMutableDictionary *temporaryCache;

@end

@implementation EDDCachingAgent

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static EDDCachingAgent *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[EDDCachingAgent alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.temporaryCache = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setCacheForSite:(NSInteger)siteID forCacheType:(EDDCacheType)type data:(NSDictionary *)cachedData
{
    NSString *siteIdentifier = [NSString stringWithFormat:@"EDD_Site_%ld", (long)siteID];
    self.temporaryCache[siteIdentifier] = cachedData;
}

- (NSDictionary *)fetchCacheForSite:(NSInteger)siteID forCacheType:(EDDCacheType)type
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"EDD_Site_%ld", (long) siteID]];
    NSString *filePath;
    
    switch (type) {
        case EDDStatsCache:
            filePath = [folderPath stringByAppendingPathComponent: @"stats.eddcache"];
            break;
        case EDDSalesCache:
            filePath = [folderPath stringByAppendingPathComponent: @"sales.eddcache"];
            break;
        case EDDEarningsCache:
            filePath = [folderPath stringByAppendingPathComponent: @"earnings.eddcache"];
            break;
        case EDDCommissionsCache:
            filePath = [folderPath stringByAppendingPathComponent: @"commissions.eddcache"];
            break;
        case EDDReviewsCache:
            filePath = [folderPath stringByAppendingPathComponent: @"reviews.eddcache"];
            break;
        default:
            break;
    }
    
    return (NSDictionary *) [[NSKeyedUnarchiver unarchiveObjectWithFile:filePath] copy];
}

- (void)saveCacheForSite:(NSInteger)siteID forCacheType:(EDDCacheType)type
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"EDD_Site_%ld", (long) siteID]];
        NSString *filePath;
        
        switch (type) {
            case EDDStatsCache:
                filePath = [folderPath stringByAppendingPathComponent:@"stats.eddcache"];
                break;
            case EDDSalesCache:
                filePath = [folderPath stringByAppendingPathComponent:@"sales.eddcache"];
                break;
            case EDDEarningsCache:
                filePath = [folderPath stringByAppendingPathComponent:@"earnings.eddcache"];
                break;
            case EDDCommissionsCache:
                filePath = [folderPath stringByAppendingPathComponent:@"commissions.eddcache"];
                break;
            case EDDReviewsCache:
                filePath = [folderPath stringByAppendingPathComponent:@"reviews.eddcache"];
                break;
            default:
                break;
        }
        
        [NSKeyedArchiver archiveRootObject:self.temporaryCache toFile:filePath];
    });
}

- (BOOL)cacheExistsForSite:(NSInteger)siteID forCacheType:(EDDCacheType)type
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"EDD_Site_%ld", (long) siteID]];
    NSString *filePath;
    
    switch (type) {
        case EDDStatsCache:
            filePath = [folderPath stringByAppendingPathComponent: @"stats.eddcache"];
            break;
        case EDDSalesCache:
            filePath = [folderPath stringByAppendingPathComponent: @"sales.eddcache"];
            break;
        case EDDEarningsCache:
            filePath = [folderPath stringByAppendingPathComponent: @"earnings.eddcache"];
            break;
        case EDDCommissionsCache:
            filePath = [folderPath stringByAppendingPathComponent: @"commissions.eddcache"];
            break;
        case EDDReviewsCache:
            filePath = [folderPath stringByAppendingPathComponent: @"reviews.eddcache"];
            break;
        default:
            break;
    }

    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

@end