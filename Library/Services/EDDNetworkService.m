//
//  EDDNetworkService.m
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 25/12/2015.
//  Copyright © 2015 Easy Digital Downloads. All rights reserved.
//

#import "Reachability.h"
#import "EDDAppDelegate.h"
#import "EDDNetworkService.h"
#import "EDDSite.h"

@interface EDDNetworkService ()

@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSMutableDictionary *cache;

@end

@implementation EDDNetworkService

+ (id)sharedInstance{
    static dispatch_once_t onceToken;
    static EDDNetworkService *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[EDDNetworkService alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cache = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)fetchStats:(void (^)(NSDictionary *stats))completionBlock
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *statsURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/edd-api/stats?key=%@&token=%@", self.site.siteURL, self.site.apiKey, self.site.token]];
    NSURLRequest *request = [NSURLRequest requestWithURL:statsURL];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *parseError = nil;
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        self.cache[@"stats"] = responseDictionary;
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(responseDictionary);
        });
    }];
    [task resume];
}

- (void)fetchSales:(NSInteger)page completionBlock:(void (^)(NSDictionary *sales))completionBlock
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *statsURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/edd-api/sales?key=%@&token=%@&page=%ld&number=30", self.site.siteURL, self.site.apiKey, self.site.token, (long) page]];
    NSURLRequest *request = [NSURLRequest requestWithURL:statsURL];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"%@", statsURL);
        NSError *parseError = nil;
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        self.cache[@"stats"] = responseDictionary;
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(responseDictionary);
        });
    }];
    [task resume];
}

- (void)fetchEarnings:(NSInteger)page completionBlock:(void (^)(NSDictionary *earnings))completionBlock
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *statsURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/edd-api/earnings?key=%@&token=%@", self.site.siteURL, self.site.apiKey, self.site.token]];
    NSURLRequest *request = [NSURLRequest requestWithURL:statsURL];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *parseError = nil;
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        self.cache[@"earnings"] = responseDictionary;
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(responseDictionary);
        });
    }];
    [task resume];
}

- (void)fetchCustomers:(NSInteger)page completionBlock:(void (^)(NSDictionary *customers))completionBlock
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *statsURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/edd-api/customers?key=%@&token=%@", self.site.siteURL, self.site.apiKey, self.site.token]];
    NSURLRequest *request = [NSURLRequest requestWithURL:statsURL];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *parseError = nil;
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        self.cache[@"customers"] = responseDictionary;
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(responseDictionary);
        });
    }];
    [task resume];
}

- (void)fetchReviews:(NSInteger)page completionBlock:(void (^)(NSDictionary *reviews))completionBlock
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *statsURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/edd-api/reviews?key=%@&token=%@", self.site.siteURL, self.site.apiKey, self.site.token]];
    NSURLRequest *request = [NSURLRequest requestWithURL:statsURL];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *parseError = nil;
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        self.cache[@"reviews"] = responseDictionary;
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(responseDictionary);
        });
    }];
    [task resume];
}

- (void)fetchCommissions:(NSInteger)page completionBlock:(void (^)(NSDictionary *commissions))completionBlock
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *statsURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/edd-api/commissions?key=%@&token=%@", self.site.siteURL, self.site.apiKey, self.site.token]];
    NSURLRequest *request = [NSURLRequest requestWithURL:statsURL];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *parseError = nil;
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        self.cache[@"commissions"] = responseDictionary;
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(responseDictionary);
        });
    }];
    [task resume];
}

- (void)fetchStoreCommissions:(NSInteger)page completionBlock:(void (^)(NSDictionary *storeCommissions))completionBlock
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *statsURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/edd-api/store-commissions?key=%@&token=%@&number=30", self.site.siteURL, self.site.apiKey, self.site.token]];
    NSURLRequest *request = [NSURLRequest requestWithURL:statsURL];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *parseError = nil;
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        self.cache[@"store-commissions"] = responseDictionary;
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(responseDictionary);
        });
    }];
    [task resume];
}

- (void)fetchGraphData:(NSString *)endpoint completionBlock:(void (^)(NSDictionary *graphData))completionBlock
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSDate *sevenDaysAgo = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay
                                                                    value:-6
                                                                   toDate:[NSDate date]
                                                                  options:0];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyyMMdd"];
    NSString *startDate = [df stringFromDate:sevenDaysAgo];
    NSString *endDate = [df stringFromDate:[NSDate date]];
    
    NSURL *statsURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/edd-api/stats?key=%@&token=%@&type=%@&date=range&startdate=%@&enddate=%@", self.site.siteURL, self.site.apiKey, self.site.token, endpoint, startDate, endDate]];
    NSLog(@"%@", statsURL);
    NSURLRequest *request = [NSURLRequest requestWithURL:statsURL];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *parseError = nil;
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        self.cache[endpoint][@"graph"] = responseDictionary;
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(responseDictionary);
        });
    }];
    [task resume];
}

@end