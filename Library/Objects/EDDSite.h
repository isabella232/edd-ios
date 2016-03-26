//
//  EDDSite.h
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 24/12/2015.
//  Copyright © 2015 Easy Digital Downloads. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, EDDSiteType)
{
    EDDStandard,
    EDDStandardAndCommission,
    EDDCommission,
    EDDStandardAndStore
};

typedef NS_ENUM(NSInteger, EDDDashboardCellType)
{
    EDDSales,
    EDDEarnings,
    EDDCommissions,
    EDDStoreCommissions,
    EDDReviews
};

@interface EDDSite : NSObject <NSCoding>

@property (nonatomic, strong) NSString *siteName;
@property (nonatomic, strong) NSString *siteURL;
@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *currency;
@property (nonatomic, strong) NSString *type;
@property (nonatomic) NSInteger siteID;
@property (nonatomic) EDDSiteType siteType;
@property (nonatomic, strong) NSArray *dashboardOrder;

@end