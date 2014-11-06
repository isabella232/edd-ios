//
//  EDDCommission.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 2/24/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import "EDDCommission.h"

@implementation EDDCommission

@synthesize amount = _amount;
@synthesize rate = _rate;
@synthesize currency = _currency;
@synthesize item = _item;

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
	
    _amount = [[attributes valueForKeyPath:@"amount"] floatValue];
    
    _rate = [[attributes valueForKeyPath:@"rate"] floatValue];
    
    _currency = [attributes valueForKeyPath:@"currency"];
    
    _item = [attributes valueForKeyPath:@"item"];
    
    _status = [attributes valueForKeyPath:@"status"];
    
    _date = [attributes valueForKeyPath:@"date"];
	
	return self;
}

+ (void)globalCommissionsWithBlock:(void (^)(NSArray *unpaid, NSArray *paid, float unpaidTotal, float paidTotal, NSError *error))block {
	NSMutableDictionary *params = [EDDAPIClient defaultParams];
    
	[params setValue:@"commissions" forKey:@"edd-api"];
	
	[[EDDAPIClient sharedClient] getPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
		NSArray *unpaidFromResponse = [JSON valueForKeyPath:@"unpaid"];
		NSArray *paidFromResponse = [JSON valueForKeyPath:@"paid"];
		NSDictionary *totalsFromResponse = [JSON valueForKeyPath:@"totals"];
		
        NSMutableArray *mutableUnpaid = [NSMutableArray arrayWithCapacity:[unpaidFromResponse count]];
        NSMutableArray *mutablePaid = [NSMutableArray arrayWithCapacity:[paidFromResponse count]];
		
        for (NSDictionary *attributes in unpaidFromResponse) {
            EDDCommission *commission = [[EDDCommission alloc] initWithAttributes:attributes];
            [mutableUnpaid addObject:commission];
        }
		
        for (NSDictionary *attributes in paidFromResponse) {
            EDDCommission *commission = [[EDDCommission alloc] initWithAttributes:attributes];
            [mutablePaid addObject:commission];
        }
		
		float unpaidTotal = [[totalsFromResponse valueForKeyPath:@"unpaid"] floatValue];
		float paidTotal = [[totalsFromResponse valueForKeyPath:@"paid"] floatValue];
		      
        if (block) {
            block([NSArray arrayWithArray:mutableUnpaid], [NSArray arrayWithArray:mutablePaid], unpaidTotal, paidTotal, nil);
        }
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (block) {
			block([NSArray array], [NSArray array], 0.0f, 0.0f, error);
		}
	}];
}

+ (void)globalStoreCommissions:(NSInteger)page block:(void (^)(NSArray *commissions, float totalUnpaid, NSError *error))block {
    NSMutableDictionary *params = [EDDAPIClient defaultParams];
    
    [params setValue:@"store-commissions" forKey:@"edd-api"];
    
    [params setValue:[NSString stringWithFormat:@"%ld", (long)page] forKey:@"page"];
    
    [[EDDAPIClient sharedClient] getPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *commissionsFromResponse = [JSON valueForKeyPath:@"commissions"];
        
        NSMutableArray *mutableCommissions = [NSMutableArray arrayWithCapacity:[commissionsFromResponse count]];
        
        for (NSDictionary *attributes in commissionsFromResponse) {
            EDDCommission *commission = [[EDDCommission alloc] initWithAttributes:attributes];
            
            [mutableCommissions addObject:commission];
        }
        
        float unpaidTotal = [[JSON valueForKeyPath:@"total_unpaid"] floatValue];
		      
        if (block) {
            block([NSArray arrayWithArray:mutableCommissions], unpaidTotal, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block([NSArray array], 0.0f, error);
        }
    }];
}

@end
