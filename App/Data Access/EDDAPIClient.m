//
//  EDDAPIClient.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/7/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "EDDAPIClient.h"

#import "AFJSONRequestOperation.h"
#import "EDDSettingsHelper.h"

static EDDAPIClient *_sharedClient = nil;

@implementation EDDAPIClient

+ (EDDAPIClient *)sharedClient {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
		NSString *clientUrl = [EDDSettingsHelper getUrlForClient];
		NSURL *url = [NSURL URLWithString:clientUrl];
        _sharedClient = [[EDDAPIClient alloc] initWithBaseURL:url];
    });
    
    return _sharedClient;
}

+ (NSMutableDictionary *)defaultParams {
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setValue:[EDDSettingsHelper getApiKey] forKey:@"key"];
	[params setValue:[EDDSettingsHelper getToken] forKey:@"token"];
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
	NSString *clientUrl = [EDDSettingsHelper getUrlForClient];
	NSURL *url = [NSURL URLWithString:clientUrl];
	_sharedClient = [[EDDAPIClient alloc] initWithBaseURL:url];
}

@end
