//
//  EDDAPIClient.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/7/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

#define PAGING_RETURN 10

@interface EDDAPIClient : AFHTTPClient

+ (EDDAPIClient *)sharedClient;

+ (NSMutableDictionary *)defaultParams;

- (void)reload;

@end
