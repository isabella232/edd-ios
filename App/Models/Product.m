//
//  Product.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/8/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "Product.h"

#import "NSString+DateHelper.h"
#import "SettingsHelper.h"

@implementation Product

@synthesize productID = _productID;
@synthesize slug = _slug;
@synthesize title = _title;
@synthesize createdDate = _createdDate;
@synthesize modifiedDate = _modifiedDate;
@synthesize status = _status;
@synthesize link = _link;
@synthesize content = _content;
@synthesize thumbnail = _thumbnail;
@synthesize totalSales = _totalSales;
@synthesize totalEarnings = _totalEarnings;
@synthesize monthlySalesAverage = _monthlySalesAverage;
@synthesize price = _price;
@synthesize notes = _notes;

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }

	_notes = [attributes valueForKey:@"notes"];
	
	NSDictionary *infoDict = [attributes valueForKey:@"info"];
    
    _productID = [[infoDict valueForKeyPath:@"id"] integerValue];
    _slug = [infoDict valueForKeyPath:@"slug"];
    _title = [infoDict valueForKeyPath:@"title"];
    _createdDate = [[infoDict objectForKey:@"create_date"] dateValue];
    _modifiedDate = [[infoDict objectForKey:@"modified_date"] dateValue];
	_status = [infoDict valueForKeyPath:@"status"];
	_link = [infoDict valueForKey:@"link"];
	_content = [infoDict valueForKey:@"content"];
	_thumbnail = [infoDict valueForKey:@"thumbnail"];
	
	NSDictionary *salesDict = [attributes valueForKey:@"stats"];
	NSDictionary *totalSalesDict = [salesDict valueForKey:@"total"];
	NSDictionary *monthlySalesDict = [salesDict valueForKey:@"monthly_average"];

	_totalSales = [[totalSalesDict valueForKey:@"sales"] intValue];
	_totalEarnings = [[totalSalesDict valueForKey:@"earnings"] floatValue];
	
	_monthlySalesAverage = [[monthlySalesDict valueForKey:@"sales"] intValue];
	_monthlyEarningsAverage = [[monthlySalesDict valueForKey:@"earnings"] floatValue];
	
	_price = [[[attributes valueForKey:@"pricing"] valueForKey:@"amount"] floatValue];
    
    return self;
}

+ (void)globalProductsWithPage:(int)page andWithBlock:(void (^)(NSArray *sales, NSError *error))block {
	NSMutableDictionary *params = [EDDAPIClient defaultParams];
	[params setValue:@"products" forKey:@"edd-api"];
	[params setValue:[NSString stringWithFormat:@"%i", page] forKey:@"page"];

	[[EDDAPIClient sharedClient] getPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
		NSArray *productsFromResponse = [JSON valueForKeyPath:@"products"];
        NSMutableArray *mutableProducts = [NSMutableArray arrayWithCapacity:[productsFromResponse count]];
		
        for (NSDictionary *attributes in productsFromResponse) {
            Product *product = [[Product alloc] initWithAttributes:attributes];
            [mutableProducts addObject:product];
        }
        
        if (block) {
            block([NSArray arrayWithArray:mutableProducts], nil);
        }
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (block) {
			block([NSArray array], error);
		}
	}];
}

@end



