//
//  Sale.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/8/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "Sale.h"

#import "SaleProduct.h"
#import "NSString+DateHelper.h"
#import "SettingsHelper.h"
#import "SaleFee.h"

@implementation Sale

@synthesize saleID = _saleID;
@synthesize subtotal = _subtotal;
@synthesize tax = _tax;
@synthesize fees = _fees;
@synthesize total = _total;
@synthesize gateway = _gateway;
@synthesize email = _email;
@synthesize date = _date;
@synthesize products = _products;
@synthesize discounts = _discounts;

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _saleID = [[attributes valueForKeyPath:@"ID"] integerValue];
    _subtotal = [[attributes valueForKeyPath:@"subtotal"] floatValue];
    _tax = [[attributes valueForKeyPath:@"tax"] floatValue];
	
    _total = [[attributes valueForKeyPath:@"total"] floatValue];
    _gateway = [[attributes valueForKeyPath:@"gateway"] capitalizedString];
    _email = [attributes valueForKeyPath:@"email"];
    _date = [[attributes objectForKey:@"date"] dateValue];

	NSMutableArray *productsArray = [NSMutableArray array];
	for (NSDictionary *productDictionary in [attributes valueForKeyPath:@"products"]) {
		[productsArray addObject:[[SaleProduct alloc] initWithAttributes:productDictionary]];
	}
	
	_products = productsArray;
	
	NSMutableArray *feesArray = [NSMutableArray array];
	for (NSDictionary *feeDictionary in [attributes valueForKeyPath:@"fees"]) {
		[feesArray addObject:[[SaleFee alloc] initWithAttributes:feeDictionary]];
	}
	
	_fees = feesArray;
	
	NSMutableArray *discountsArray = [NSMutableArray array];
	for (NSString *discount in [attributes valueForKeyPath:@"discount"]) {
		[discountsArray addObject:discount];
	}
	
	_discounts = discountsArray;
	
    return self;
}

- (NSString *)discountFormat {
	NSString *format = @"";
	
	for (NSString *discount in self.discounts) {
        format = [format stringByAppendingString:[NSString stringWithFormat:@"%@,", discount]];
	}
    
    // remove comma
    if (format.length > 0) {
        format = [format substringToIndex:[format length] - 1];
    }
	
	return format;
}

+ (void)globalSalesWithPage:(int)page andWithBlock:(void (^)(NSArray *sales, NSError *error))block {
	NSMutableDictionary *params = [EDDAPIClient defaultParams];
	[params setValue:@"sales" forKey:@"edd-api"];
	[params setValue:[NSString stringWithFormat:@"%i", page] forKey:@"page"];
	
	[[EDDAPIClient sharedClient] getPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
		NSArray *salesFromResponse = [JSON valueForKeyPath:@"sales"];
        NSMutableArray *mutableSales = [NSMutableArray arrayWithCapacity:[salesFromResponse count]];
		
        for (NSDictionary *attributes in salesFromResponse) {
            Sale *sale = [[Sale alloc] initWithAttributes:attributes];
            [mutableSales addObject:sale];
        }
        
        if (block) {
            block([NSArray arrayWithArray:mutableSales], nil);
        }
	
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (block) {
			block([NSArray array], error);
		}
	}];
}

@end
