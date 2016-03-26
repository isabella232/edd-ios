//
//  EDDDashboardStaticTableViewCell.h
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 26/12/2015.
//  Copyright © 2015 Easy Digital Downloads. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EDDSite.h"

typedef NS_ENUM(NSUInteger, EDDDashboardStaticTableViewCellType)
{
    EDDSalesCell,
    EDDEarningsCell,
    EDDCommissionsCell,
    EDDReviewsCell
};

@interface EDDDashboardStaticTableViewCell : UITableViewCell

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *stat;
@property (nonatomic, strong) EDDSite *site;
@property (nonatomic) BOOL currencyFormatted;
@property (nonatomic) BOOL isSales;
@property (nonatomic) BOOL isEarnings;
@property (nonatomic) BOOL isCommissions;
@property (nonatomic) BOOL isStoreCommissions;
@property (nonatomic) BOOL isReviews;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic) EDDDashboardStaticTableViewCellType *cellType;

- (void)configureTitle;
- (void)configureWithProperties;
- (void)drawAdditionalSubviews;
- (void)resizeForSmallCell;
- (void)resizeForNormalCell;
- (void)resizeForLargeCell;
- (void)spin;

@end