//
//  EDDCustomer.h
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 01/01/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EDDCustomer : NSObject <NSCoding>

@property (nonatomic) NSInteger *userID;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic) NSInteger *customerID;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSDictionary *stats;

@end
