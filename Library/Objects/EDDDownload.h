//
//  EDDDownload.h
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 01/01/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EDDDownload : NSObject <NSCoding>

@property (nonatomic) NSInteger productID;
@property (nonatomic, strong) NSString *slug;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSDate *modififed;
@property (nonatomic, strong) NSString *link;
@property (nonatomic) BOOL hasThumbnail;
@property (nonatomic, strong) NSString *thumbnailURL;
@property (nonatomic, strong) NSString *content;
@property (nonatomic) BOOL hasCategories;
@property (nonatomic, strong) NSDictionary *categories;
@property (nonatomic) BOOL hasTags;
@property (nonatomic, strong) NSDictionary *tags;
@property (nonatomic, strong) NSDictionary *stats;
@property (nonatomic) BOOL hasVariablePricing;
@property (nonatomic, strong) NSDictionary *pricing;
@property (nonatomic) BOOL hasFiles;
@property (nonatomic, strong) NSDictionary *files;

@end
