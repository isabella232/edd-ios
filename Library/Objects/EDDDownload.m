//
//  EDDDownload.m
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 01/01/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

#import "EDDDownload.h"

@implementation EDDDownload

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.downloadID = [aDecoder decodeIntegerForKey:@"downloadID"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.created = [aDecoder decodeObjectForKey:@"created"];
        self.link = [aDecoder decodeObjectForKey:@"link"];
        self.hasThumbnail = [aDecoder decodeBoolForKey:@"hasThumbnail"];
        self.thumbnailURL = [aDecoder decodeObjectForKey:@"thumbnailURL"];
        self.content = [aDecoder decodeObjectForKey:@"content"];
        self.hasCategories = [aDecoder decodeBoolForKey:@"hasCategories"];
        self.categories = [aDecoder decodeObjectForKey:@"categories"];
        self.hasTags = [aDecoder decodeBoolForKey:@"hasTags"];
        self.tags = [aDecoder decodeObjectForKey:@"tags"];
        self.stats = [aDecoder decodeObjectForKey:@"stats"];
        self.hasVariablePricing = [aDecoder decodeBoolForKey:@"hasVariablePricing"];
        self.pricing = [aDecoder decodeObjectForKey:@"pricing"];
        self.hasFiles = [aDecoder decodeBoolForKey:@"hasFiles"];
        self.files = [aDecoder decodeObjectForKey:@"files"];
        self.hasLicensing = [aDecoder decodeBoolForKey:@"hasLicensing"];
        self.licensing = [aDecoder decodeObjectForKey:@"licensing"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.downloadID forKey:@"downloadID"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.created forKey:@"created"];
    [aCoder encodeObject:self.link forKey:@"link"];
    [aCoder encodeBool:self.hasThumbnail forKey:@"hasThumbnail"];
    [aCoder encodeObject:self.thumbnailURL forKey:@"thumbnailURL"];
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeBool:self.hasCategories forKey:@"hasCategories"];
    [aCoder encodeObject:self.categories forKey:@"categories"];
    [aCoder encodeBool:self.hasTags forKey:@"hasTags"];
    [aCoder encodeObject:self.tags forKey:@"tags"];
    [aCoder encodeObject:self.stats forKey:@"stats"];
    [aCoder encodeBool:self.hasVariablePricing forKey:@"hasVariablePricing"];
    [aCoder encodeObject:self.pricing forKey:@"pricing"];
    [aCoder encodeBool:self.hasFiles forKey:@"hasFiles"];
    [aCoder encodeObject:self.files forKey:@"files"];
    [aCoder encodeBool:self.hasLicensing forKey:@"hasLicensing"];
    [aCoder encodeObject:self.licensing forKey:@"licensing"];
}

@end