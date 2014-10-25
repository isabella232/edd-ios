//
//  EDDCustomer.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/9/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "EDDCustomer.h"

#import "EDDAPIClient.h"
#import "EDDSettingsHelper.h"

@implementation EDDCustomer

@synthesize customerID = _customerID;
@synthesize userName = _userName;
@synthesize displayName = _displayName;
@synthesize firstName = _firstName;
@synthesize lastName = _lastName;
@synthesize email = _email;
@synthesize totalPurchases = _totalPurchases;
@synthesize totalSpent = _totalSpent;
@synthesize totalDownloads = _totalDownloads;

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
	
    NSDictionary *infoDict = [attributes valueForKey:@"info"];
    
    _customerID = [[infoDict valueForKeyPath:@"customer_id"] integerValue];
    
    _wordpressID = [[infoDict valueForKeyPath:@"id"] integerValue];
    
    _userName = [infoDict valueForKeyPath:@"username"];
    
    _firstName = [infoDict valueForKeyPath:@"first_name"];
    
    _lastName = [infoDict valueForKeyPath:@"last_name"];
    
    NSString *displayName  = [infoDict valueForKeyPath:@"display_name"];
    
    _displayName ? displayName : [NSString stringWithFormat:@"%@ %@", _firstName, _lastName];
    _email = [infoDict valueForKeyPath:@"email"];
	
	NSDictionary *statsDict = [attributes valueForKey:@"stats"];
	
	_totalPurchases	= [[statsDict valueForKeyPath:@"total_purchases"] integerValue];
	_totalSpent = [[statsDict valueForKeyPath:@"total_spent"] floatValue];
    _totalDownloads = [[statsDict valueForKeyPath:@"total_downloads"] integerValue];
	
	return self;
}

- (NSString *)displayName {
    return _displayName ? _displayName : [NSString stringWithFormat:@"%@ %@", _firstName, _lastName];
}

+ (void)globalCustomersWithPage:(NSInteger)page andWithBlock:(void (^)(NSArray *customers, NSError *error))block {
	NSMutableDictionary *params = [EDDAPIClient defaultParams];
    
    [params setValue:@"customers" forKey:@"edd-api"];
    
    [params setValue:[NSString stringWithFormat:@"%li", (long)page] forKey:@"page"];
	
    [[EDDAPIClient sharedClient] getPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *customersFromResponse = [JSON valueForKeyPath:@"customers"];
        
        NSMutableArray *mutableCustomers = [NSMutableArray arrayWithCapacity:[customersFromResponse count]];
        
        for (NSDictionary *attributes in customersFromResponse) {
            EDDCustomer *customer = [[EDDCustomer alloc] initWithAttributes:attributes];
            [mutableCustomers addObject:customer];
        }
        
        if (block) {
            block([NSArray arrayWithArray:mutableCustomers], nil);
        }
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (block) {
			block([NSArray array], error);
		}
	}];
}

+ (void)customersWithEmail:(NSString *)email page:(NSInteger)page block:(void (^)(NSArray *customers, NSError *error))block {
    NSMutableDictionary *params = [EDDAPIClient defaultParams];
    [params setValue:@"customers" forKey:@"edd-api"];
    
    [params setValue:email forKey:@"customer"];
    
    [params setValue:[NSString stringWithFormat:@"%li", (long)page] forKey:@"page"];
    
    [[EDDAPIClient sharedClient] getPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *customersFromResponse = [JSON valueForKeyPath:@"customers"];
        
        NSMutableArray *mutableCustomers = [NSMutableArray arrayWithCapacity:[customersFromResponse count]];
        
        for (NSDictionary *attributes in customersFromResponse) {
            EDDCustomer *customer = [[EDDCustomer alloc] initWithAttributes:attributes];
            [mutableCustomers addObject:customer];
        }
        
        if (block) {
            block([NSArray arrayWithArray:mutableCustomers], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block([NSArray array], error);
        }
    }];
}

@end
