//
//  EDDDashboardViewController.m
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 25/12/2015.
//  Copyright © 2015 Easy Digital Downloads. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "Reachability.h"

#import "EDDNetworkService.h"
#import "EDDDashboardViewController.h"
#import "EDDSite.h"
#import "EDDHeaderLabel.h"
#import "EDDDashboardStaticTableViewCell.h"
#import "EDDHighlightButton.h"
#import "EDDSiteSwitchViewController.h"
#import "EDDCachingAgent.h"
#import "EDDEditDashboardViewController.h"

@class BEMSimpleLineGraphView;

@interface EDDDashboardViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) EDDSite *site;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) EDDHeaderLabel *headerView;
@property (nonatomic, strong) NSMutableDictionary *data;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic) BOOL salesStatsCompleted;
@property (nonatomic) BOOL earningsStatsCompleted;
@property (nonatomic) BOOL commissionsStatsCompleted;
@property (nonatomic) BOOL storeCommissionsStatsCompleted;

@property (nonatomic, strong) Reachability *internetReachable;

@end

@implementation EDDDashboardViewController

- (instancetype)initWithSite:(EDDSite *)site
{
    self = [super init];
    if (self) {
        self.site = site;
        self.data = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarTapped) name:@"touchStatusBarTap" object:nil];
    
    self.title = NSLocalizedString(@"Dashboard", @"");
    self.navigationItem.title = NSLocalizedString(@"Dashboard", @"");
    
    UIImage *image = [UIImage imageNamed:@"NavBarSiteSwitch"];
    EDDHighlightButton *siteSwitchButton = [EDDHighlightButton buttonWithType:UIButtonTypeCustom];
    siteSwitchButton.tintColor = [UIColor whiteColor];
    [siteSwitchButton setImage:image forState:UIControlStateNormal];
    siteSwitchButton.frame = CGRectMake(0.0, 0.0, image.size.width + 64, image.size.height);
    siteSwitchButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 44);
    [siteSwitchButton addTarget:self action:@selector(siteSwitcherButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:siteSwitchButton];
    [leftButton setAccessibilityLabel:NSLocalizedString(@"Switch Site", @"")];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", @"") style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPressed:)];
    
    UIBarButtonItem *spacerButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spacerButton.width = -16.0;
    
    self.navigationItem.leftBarButtonItems = @[spacerButton, leftButton];
    self.navigationItem.rightBarButtonItems = @[rightButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadCachedDataIfExists];
    
    [self setupTableView];
    [self setupHeaderView];
    
    [self loadData:nil];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(loadData:)
                  forControlEvents:UIControlEventValueChanged];
    [self.refreshControl setBackgroundColor:[UIColor whiteColor]];
    [self.tableView addSubview:self.refreshControl];
    [self.tableView sendSubviewToBack:self.refreshControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)checkNetworkStatus:(NSNotification *)notice
{
    NetworkStatus internetStatus = [self.internetReachable currentReachabilityStatus];
    if (internetStatus == ReachableViaWiFi) {
        NSLog(@"Reachable via Wi-Fi");
    }
    
    if (internetStatus == NotReachable) {
        NSLog(@"Not reachable");
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupHeaderView
{
    UIFont *boldFont = [UIFont boldSystemFontOfSize:20.0f];

    self.headerView = [[EDDHeaderLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.headerView.backgroundColor = [UIColor whiteColor];
    self.headerView.text = self.site.siteName;
    self.headerView.textAlignment = NSTextAlignmentCenter;
    self.headerView.layer.borderColor = [UIColor clearColor].CGColor;
    self.headerView.layer.borderWidth = 1.0f;
    self.headerView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.headerView.layer.shadowRadius = 5.0f;
    self.headerView.layer.shadowOpacity = 0.2f;
    self.headerView.layer.shadowOffset = CGSizeMake(0, 4.0f);
    self.headerView.layer.masksToBounds = NO;
    self.headerView.font = boldFont;
    self.headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:self.headerView];
    
    CATransition *animation = [CATransition animation];
    animation.duration = 4.0;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.headerView.layer addAnimation:animation forKey:@"changeTextTransition"];
}

- (void)setupTableView
{
    UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.tabBarController.tabBar.frame), 0);
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.contentInset = adjustForTabbarInsets;
    self.tableView.scrollIndicatorInsets = adjustForTabbarInsets;
    self.tableView.bounces = YES;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.accessibilityIdentifier = NSLocalizedString(@"Dashboard", @"");
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView registerClass:[EDDDashboardStaticTableViewCell class] forCellReuseIdentifier:@"staticDashboardCell"];
    [self.tableView registerClass:[EDDDashboardStaticTableViewCell class] forCellReuseIdentifier:@"staticLargeDashboardCell"];
    
    [self.view addSubview:self.tableView];
}

- (void)loadCachedDataIfExists
{
    if ([[EDDCachingAgent sharedInstance] cacheExistsForSite:self.site.siteID forCacheType:EDDStatsCache]) {
        NSMutableDictionary *data = [[[EDDCachingAgent sharedInstance] fetchCacheForSite:self.site.siteID forCacheType:EDDStatsCache] copy];
        NSString *key = [NSString stringWithFormat:@"EDD_Site_%ld", (long) self.site.siteID];
        self.data = data[key];
    }
}

- (void)loadData:(UIRefreshControl *)refreshControl
{
    [UIView transitionWithView:self.headerView
                      duration:.5f
                       options:UIViewAnimationOptionCurveEaseInOut |
     UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.headerView.text = NSLocalizedString(@"Refreshing...", @"");
                    } completion:nil];
    
    _salesStatsCompleted = NO;
    _earningsStatsCompleted = NO;
    _commissionsStatsCompleted = NO;
    _storeCommissionsStatsCompleted = NO;

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(queue, ^{
        [self.refreshControl beginRefreshing];
    
        if (self.site.siteType == EDDStandard) {
            _commissionsStatsCompleted = _storeCommissionsStatsCompleted = YES;
        }
        
        EDDNetworkService *networkService = [EDDNetworkService sharedInstance];
        networkService.site = self.site;

        [networkService fetchStats:^(NSDictionary *stats) {
            self.data[@"stats"] = stats;
            [self save];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
        
        [networkService fetchGraphData:@"earnings" completionBlock:^(NSDictionary *graphData) {
            self.data[@"earnings_graph"] = graphData;
            _earningsStatsCompleted = YES;
            [self save];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
        
        [networkService fetchGraphData:@"sales" completionBlock:^(NSDictionary *graphData) {
            _salesStatsCompleted = YES;
            self.data[@"sales_graph"] = graphData;
            [self save];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
        
        if (self.site.siteType == EDDStandardAndCommission || self.site.siteType == EDDCommission || self.site.siteType == EDDStandardAndStore) {
            [networkService fetchCommissions:1 completionBlock:^(NSDictionary *commissions) {
                _commissionsStatsCompleted = YES;
                self.data[@"commissions"] = commissions;
                [self save];
                dispatch_async(dispatch_get_main_queue(), ^{
                   [self.tableView reloadData];
                });
            }];
        }
        
        if (self.site.siteType == EDDStandardAndStore) {
            [networkService fetchStoreCommissions:1 completionBlock:^(NSDictionary *storeCommissions) {
                _storeCommissionsStatsCompleted = YES;
                self.data[@"store-commissions"] = storeCommissions;
                [self save];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }];
        }
    });
    
    [self.refreshControl endRefreshing];
}

- (void)updateStats
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)save
{
    if (self.site.siteType == EDDStandard && _salesStatsCompleted && _earningsStatsCompleted) {
        [[EDDCachingAgent sharedInstance] setCacheForSite:self.site.siteID forCacheType:EDDStatsCache data:self.data];
        [[EDDCachingAgent sharedInstance] saveCacheForSite:self.site.siteID forCacheType:EDDStatsCache];
        [self updateHeaderLabel];
    }
    
    if (self.site.siteType == EDDStandardAndCommission && _salesStatsCompleted && _earningsStatsCompleted && _commissionsStatsCompleted) {
        [[EDDCachingAgent sharedInstance] setCacheForSite:self.site.siteID forCacheType:EDDStatsCache data:self.data];
        [[EDDCachingAgent sharedInstance] saveCacheForSite:self.site.siteID forCacheType:EDDStatsCache];
        [self updateHeaderLabel];
    }
    
    if (self.site.siteType == EDDStandardAndStore && _salesStatsCompleted && _earningsStatsCompleted && _commissionsStatsCompleted && _storeCommissionsStatsCompleted) {
        [[EDDCachingAgent sharedInstance] setCacheForSite:self.site.siteID forCacheType:EDDStatsCache data:self.data];
        [[EDDCachingAgent sharedInstance] saveCacheForSite:self.site.siteID forCacheType:EDDStatsCache];
        [self updateHeaderLabel];
    }
    
    if (self.site.siteType == EDDCommission && _commissionsStatsCompleted) {
        [[EDDCachingAgent sharedInstance] setCacheForSite:self.site.siteID forCacheType:EDDStatsCache data:self.data];
        [[EDDCachingAgent sharedInstance] saveCacheForSite:self.site.siteID forCacheType:EDDStatsCache];
        [self updateHeaderLabel];
    }
}

- (void)updateHeaderLabel
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView transitionWithView:self.headerView
                          duration:.5f
                           options:UIViewAnimationOptionCurveEaseInOut |
         UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.headerView.text = self.site.siteName;
                        } completion:nil];
    });
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row <= 1) {
        return 250;
    } else if (indexPath.row > 1 && indexPath.row < 3) {
        return 130;
    } else {
        return 55;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.site.siteType == EDDStandard) {
        return 2;
    } else if (self.site.siteType == EDDStandardAndCommission) {
        return 3;
    } else if (self.site.siteType == EDDStandardAndStore) {
        return 4;
    } else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EDDDashboardStaticTableViewCell *cell;
    
    static NSString *cellIdentifier;
    
    if (indexPath.row == 0 || indexPath.row == 1) {
        cellIdentifier = @"staticLargeDashboardCell";
    } else {
        cellIdentifier = @"staticDashboardCell";
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[EDDDashboardStaticTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.site = self.site;
    
    if (indexPath.row == 0) {
        cell.title = NSLocalizedString(@"Sales", @"");
        cell.stat = [NSString stringWithFormat:@"%@", self.data[@"stats"][@"stats"][@"sales"][@"today"]];
        cell.isSales = YES;
        [cell resizeForLargeCell];
    } else if (indexPath.row == 1) {
        cell.title = NSLocalizedString(@"Earnings", @"");
        cell.currencyFormatted = YES;
        cell.stat = [NSString stringWithFormat:@"%@", self.data[@"stats"][@"stats"][@"earnings"][@"today"]];
        cell.isEarnings = YES;
        [cell resizeForLargeCell];
    } else if (indexPath.row == 2 && (self.site.siteType == EDDStandardAndStore || self.site.siteType == EDDStandardAndCommission)) {
        cell.title = NSLocalizedString(@"Commissions", @"");
        if (self.data[@"commissions"][@"totals"][@"unpaid"]) {
            cell.currencyFormatted = YES;
            cell.stat = [NSString stringWithFormat:@"%@", self.data[@"commissions"][@"totals"][@"unpaid"]];
        } else {
            [cell spin];
        }

        cell.isCommissions = YES;
        [cell resizeForNormalCell];
    } else if (indexPath.row == 3 && self.site.siteType == EDDStandardAndStore) {
        cell.title = NSLocalizedString(@"Store Commissions", @"");
        if (self.data[@"store-commissions"][@"total_unpaid"]) {
            cell.currencyFormatted = YES;
            cell.stat = [NSString stringWithFormat:@"%@", self.data[@"store-commissions"][@"total_unpaid"]];
        } else {
            [cell spin];
        }
        
        cell.isStoreCommissions = YES;
        [cell resizeForSmallCell];
    }
    
    [cell drawAdditionalSubviews];
    
    [cell configureTitle];
    
    if (self.data[@"stats"]) {
        cell.data = self.data;
        [cell configureWithProperties];
        [cell setNeedsDisplay];
        return cell;
    }

//    [cell setNeedsUpdateConstraints];
//    [cell updateConstraintsIfNeeded];
    
    return cell;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation) fromInterfaceOrientation
{
    [self.tableView reloadData];
}

- (void)siteSwitcherButtonPressed:(id)sender
{
    EDDSiteSwitchViewController *viewController = [[EDDSiteSwitchViewController alloc] init];
    viewController.view.backgroundColor = [UIColor clearColor];
    viewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    viewController.modalPresentationCapturesStatusBarAppearance = YES;
    [self.tabBarController presentViewController:viewController animated:YES completion:nil];
}

- (void)editButtonPressed:(id)sender
{
    EDDEditDashboardViewController *viewController = [[EDDEditDashboardViewController alloc] initWithSite:self.site];
    viewController.view.backgroundColor = [UIColor clearColor];
    viewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    viewController.modalPresentationCapturesStatusBarAppearance = YES;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)statusBarTapped
{
    [self.tableView setContentOffset:CGPointZero animated:YES];
}

# pragma mark - EDDNetworkStatus Protocol

- (void)networkStatus:(NetworkStatus)status
{
    NSLog(@"%ld", (long)status);
}

@end