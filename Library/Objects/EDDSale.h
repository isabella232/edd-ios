//
//  EDDSale.h
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 01/01/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EDDSale : NSObject <NSCoding>

@property (nonatomic) NSInteger *saleID;
@property (nonatomic, strong) NSString *transactionID;
@property (nonatomic, strong) NSString *key;
@property (nonatomic) BOOL hasDiscount;
@property (nonatomic, strong) NSDictionary *discount;
@property (nonatomic) double subtotal;
@property (nonatomic) double tax;
@property (nonatomic) BOOL hasFees;
@property (nonatomic, strong) NSDictionary *fees;
@property (nonatomic, strong) NSString *gateway;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDictionary *products;

@end