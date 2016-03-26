//
//  EDDSite.m
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 24/12/2015.
//  Copyright © 2015 Easy Digital Downloads. All rights reserved.
//

#import "EDDSite.h"

@implementation EDDSite

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.siteName = [aDecoder decodeObjectForKey:@"siteName"];
        self.siteURL = [aDecoder decodeObjectForKey:@"siteURL"];
        self.currency = [aDecoder decodeObjectForKey:@"currency"];
        self.type = [aDecoder decodeObjectForKey:@"type"];
        self.siteID = [aDecoder decodeIntegerForKey:@"siteID"];
        self.siteType = [aDecoder decodeIntForKey:@"siteType"];
        self.dashboardOrder = [aDecoder decodeObjectForKey:@"dashboardOrder"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.siteName forKey:@"siteName"];
    [aCoder encodeObject:self.siteURL forKey:@"siteURL"];
    [aCoder encodeObject:self.currency forKey:@"currency"];
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeInteger:self.siteID forKey:@"siteID"];
    [aCoder encodeInt:self.siteType forKey:@"siteType"];
    [aCoder encodeObject:self.dashboardOrder forKey:@"dashboardOrder"];
}

@end