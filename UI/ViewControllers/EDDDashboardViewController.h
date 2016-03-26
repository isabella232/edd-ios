//
//  EDDDashboardViewController.h
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 25/12/2015.
//  Copyright © 2015 Easy Digital Downloads. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EDDSite.h"
#import "EDDViewController.h"

@interface EDDDashboardViewController : EDDViewController

@property (nonatomic, strong) NSMutableDictionary *cache;
@property (nonatomic, strong) NSMutableDictionary *siteCache;

- (instancetype)initWithSite:(EDDSite *)site;
- (void)updateStats;

@end