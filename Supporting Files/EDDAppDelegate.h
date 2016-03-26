//
//  AppDelegate.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/7/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"

@interface EDDAppDelegate : UIResponder <UIApplicationDelegate>

+ (EDDAppDelegate *)sharedEDDAppDelegate;
- (NSInteger)getDefaultSiteID;

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UINavigationController *navigationController;
@property(nonatomic, strong) id<GAITracker> tracker;

@end