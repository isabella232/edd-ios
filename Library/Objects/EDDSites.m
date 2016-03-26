//
//  EDDSites.m
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 24/12/2015.
//  Copyright © 2015 Easy Digital Downloads. All rights reserved.
//

#import "EDDSites.h"

@implementation EDDSites

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.sites = [aDecoder decodeObjectForKey:@"sites"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.sites forKey:@"sites"];
}


@end
