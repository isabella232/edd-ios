//
//  EDDSiteController.m
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 26/08/2015.
//  Copyright © 2015 Easy Digital Downloads. All rights reserved.
//

#import "EDDAppDelegate.h"
#import "EDDSites.h"
#import "EDDSite.h"
#import "EDDSiteController.h"
#import "EDDDashboardViewController.h"
#import "EDDSalesViewController.h"
#import "EDDCustomersViewController.h"
#import "EDDReportsViewController.h"
#import "EDDMoreViewController.h"
#import "EDDCommissionsViewController.h"
#import "EDDReviewsViewController.h"
#import "EDDNetworkService.h"

#import "UIColor+EDDUIColorCategory.h"

@interface EDDSiteController () <UITabBarControllerDelegate, UITabBarDelegate>

@property (nonatomic, strong) EDDSite *site;
@property (nonatomic) NSInteger defaultSiteID;
@property (nonatomic, strong) NSMutableDictionary *data;

@end

@implementation EDDSiteController

- (instancetype)initWithSite:(EDDSite *)site
{
    self = [super init];
    if (self) {
        self.site = site;
        self.view.opaque = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.view clipsToBounds];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.tabBar.translucent = NO;
    
    self.delegate = self;
    
    self.data = [NSMutableDictionary dictionary];
    
    [self initViewControllers];
}

- (void)initViewControllers
{
    EDDDashboardViewController *dashboardViewController = [[EDDDashboardViewController alloc] initWithSite:self.site];
    UINavigationController *dashboardNavigationController = [[UINavigationController alloc] initWithRootViewController:dashboardViewController];
    dashboardNavigationController.tabBarItem.image = [[UIImage imageNamed:@"TabBarDashboard"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    dashboardNavigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarDashboard-Selected"];

    if (self.site.siteType == EDDCommission) {
        
    } else {
        EDDSalesViewController *salesViewController = [[EDDSalesViewController alloc] initWithSite:self.site];
        salesViewController.title = @"Sales";
        UINavigationController *salesNavigationController = [[UINavigationController alloc] initWithRootViewController:salesViewController];
        salesNavigationController.tabBarItem.image = [[UIImage imageNamed:@"TabBarSales"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        salesNavigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarSales-Selected"];
        
        EDDCustomersViewController *customersViewController = [[EDDCustomersViewController alloc] initWithSite:self.site];
        customersViewController.title = @"Customers";
        UINavigationController *customersNavigationController = [[UINavigationController alloc] initWithRootViewController:customersViewController];
        customersNavigationController.tabBarItem.image = [[UIImage imageNamed:@"TabBarCustomers"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        customersNavigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarCustomers-Selected"];
        
        EDDReportsViewController *reportsViewController = [[EDDReportsViewController alloc] initWithSite:self.site];
        reportsViewController.title = @"Reports";
        UINavigationController *reportsNavigationController = [[UINavigationController alloc] initWithRootViewController:reportsViewController];
        reportsNavigationController.tabBarItem.image = [[UIImage imageNamed:@"TabBarReports"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        reportsNavigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarReports-Selected"];
        
        EDDMoreViewController *moreViewController = [[EDDMoreViewController alloc] initWithSite:self.site];
        moreViewController.title = @"More";
        UINavigationController *moreNavigationController = [[UINavigationController alloc] initWithRootViewController:moreViewController];
        moreNavigationController.tabBarItem.image = [[UIImage imageNamed:@"TabBarMore"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        moreNavigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"TabBarMore-Selected"];
        
        self.viewControllers = @[dashboardNavigationController, salesNavigationController, customersNavigationController, reportsNavigationController, moreNavigationController];
    }
    
    [self setSelectedViewController:dashboardNavigationController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if (tabBarController.selectedViewController == viewController) {
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navController = (UINavigationController *)viewController;
            if ([navController topViewController] == [[navController viewControllers] firstObject] &&
                [[[navController topViewController] view] isKindOfClass:[UITableView class]]) {
                UITableView *tableView = (UITableView *)[[navController topViewController] view];
                
                if ([tableView numberOfSections] > 0 && [tableView numberOfRowsInSection:0] > 0) {
                    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                }
            }
        }
    }

    return YES;
}

@end
