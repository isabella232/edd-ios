//
//  EDDAPIClient.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/7/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "EDDAPIClient.h"

#import "AFJSONRequestOperation.h"
#import "SettingsHelper.h"

static EDDAPIClient *_sharedClient = nil;

@implementation EDDAPIClient

+ (EDDAPIClient *)sharedClient {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[EDDAPIClient alloc] initWithBaseURL:[NSURL URLWithString:[SettingsHelper getUrlForClient]]];
    });
    
    return _sharedClient;
}

+ (NSDictionary *)defaultParams {
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setValue:[SettingsHelper getApiKey] forKey:@"key"];
	[params setValue:[SettingsHelper getToken] forKey:@"token"];
	return params;	
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}

- (void)reload {
    _sharedClient = [[EDDAPIClient alloc] initWithBaseURL:[NSURL URLWithString:[SettingsHelper getUrlForClient]]];
}

@end
