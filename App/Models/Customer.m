//
//  Customer.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/9/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "Customer.h"

#import "EDDAPIClient.h"
#import "SettingsHelper.h"

@implementation Customer

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
    
    _customerID = [[infoDict valueForKeyPath:@"id"] integerValue];
    _userName = [infoDict valueForKeyPath:@"username"];
    _displayName = [infoDict valueForKeyPath:@"display_name"];
    _firstName = [infoDict valueForKeyPath:@"first_name"];
    _lastName = [infoDict valueForKeyPath:@"last_name"];
    _email = [infoDict valueForKeyPath:@"email"];
	
	NSDictionary *statsDict = [attributes valueForKey:@"stats"];
	
	_totalPurchases	= [[statsDict valueForKeyPath:@"total_purchases"] integerValue];
	_totalSpent = [[statsDict valueForKeyPath:@"total_spent"] floatValue];
    _totalDownloads = [[statsDict valueForKeyPath:@"total_downloads"] integerValue];
	
	return self;
}

+ (void)globalCustomersWithBlock:(void (^)(NSArray *customers, NSError *error))block {
	NSMutableDictionary *params = [EDDAPIClient defaultParams];
	[params setValue:@"customers" forKey:@"query"];
	
	[[EDDAPIClient sharedClient] getPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
		NSArray *customersFromResponse = [JSON valueForKeyPath:@"customers"];
        NSMutableArray *mutableCustomers = [NSMutableArray arrayWithCapacity:[customersFromResponse count]];
		
//		int count;
		
        for (NSDictionary *attributes in customersFromResponse) {
//			NSDictionary *customerDict = [attributes valueForKeyPath:[NSString stringWithFormat:@"%i", count]];
            Customer *customer = [[Customer alloc] initWithAttributes:attributes];
            [mutableCustomers addObject:customer];
//			count++;
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
