//
//  AppDelegate.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/7/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UISplitViewControllerDelegate>

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) UINavigationController *navigationController;

@property (nonatomic, strong) UISplitViewController *splitViewController;

@end
