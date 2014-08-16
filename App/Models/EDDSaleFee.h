//
//  EDDSaleFee.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/17/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EDDSaleFee : NSObject

@property (readonly) NSString *name;
@property (readonly) float cost;

- (id)initWithAttributes:(NSDictionary *)attributes;

@end
