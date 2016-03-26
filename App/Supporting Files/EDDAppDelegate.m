//
//  AppDelegate.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/7/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "EDDAppDelegate.h"

#import "AFNetworkActivityIndicatorManager.h"
#import "EDDAppDefines.h"
#import "EDDAnalytics.h"
#import "EDDHelpers.h"
#import "EDDSlideMenuController.h"
#import "EDDMainViewController.h"
#import "EDDMenuViewController.h"
#import "UIColor+Helpers.h"
#import <Crashlytics/Crashlytics.h>

@implementation AppDelegate

+ (AppDelegate *)sharedAppDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {	
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	
	[[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
	[ARAnalytics setupWithAnalytics:@{
									  ARCrashlyticsAPIKey : kCrashlyticsId,
									  ARGoogleAnalyticsID : kAnalyticsTrackerId
                                      }];
    
    [self applyStyleSheet];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor clearColor];
	
	EDDMainViewController *mainViewController = [[EDDMainViewController alloc] init];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:mainViewController];
	nav.navigationBar.translucent = NO;
    
    EDDMenuViewController *menuViewController = [[EDDMenuViewController alloc] init];
    self.menuViewController = menuViewController;
    
    if ([EDDHelpers isHandset]) {
        NVSlideMenuController *slideMenuController = [[NVSlideMenuController alloc] initWithMenuViewController:menuViewController andContentViewController:nav];
        self.window.rootViewController = slideMenuController;
    } else {
        self.splitViewController = [[UISplitViewController alloc] init];
        self.splitViewController.viewControllers = @[ menuViewController, nav ];
        self.splitViewController.delegate = self;
        self.window.rootViewController = self.splitViewController;
    }
    
	[self.window makeKeyAndVisible];
	
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)applyStyleSheet {
	UINavigationBar *navigationBar = [UINavigationBar appearance];
    [navigationBar setTintColor:[UIColor whiteColor]];
	[navigationBar setBarTintColor:[UIColor colorWithHexString:@"#1c5585"]];
	[navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Split View Delegate

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    return NO;
}

@end
