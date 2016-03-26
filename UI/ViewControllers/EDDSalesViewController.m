//
//  EDDSalesViewController.m
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 25/12/2015.
//  Copyright © 2015 Easy Digital Downloads. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "EDDSalesViewController.h"
#import "EDDSite.h"
#import "EDDHeaderLabel.h"
#import "EDDSalesTableViewCell.h"
#import "EDDCachingAgent.h"
#import "EDDNetworkService.h"

#import "UIColor+EDDUIColorCategory.h"

@interface EDDSalesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) EDDSite *site;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) EDDHeaderLabel *headerView;
@property (nonatomic, strong) NSMutableDictionary *data;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic) BOOL downloadComplete;

@end

@implementation EDDSalesViewController

- (instancetype)initWithSite:(EDDSite *)site
{
    self = [super init];
    if (self) {
        self.site = site;
        self.title = NSLocalizedString(@"Sales", @"");
        self.navigationItem.title = NSLocalizedString(@"Sales", @"");
        self.data = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarTapped) name:@"touchStatusBarTap" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadCachedDataIfExists];
    
    [self loadData:nil];
    
    [self setupTableView];
    [self setupHeaderView];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(loadData:)
                  forControlEvents:UIControlEventValueChanged];
    [self.refreshControl setBackgroundColor:[UIColor whiteColor]];
    [self.tableView addSubview:self.refreshControl];
    [self.tableView sendSubviewToBack:self.refreshControl];
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
    
    [self.view addSubview:self.headerView];
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
    self.tableView.accessibilityIdentifier = NSLocalizedString(@"Sales", @"");
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView registerClass:[EDDSalesTableViewCell class] forCellReuseIdentifier:@"salesCell"];
    self.tableView.backgroundColor = [UIColor EDDGreyColor];
    
    [self.view addSubview:self.tableView];
}

- (void)loadCachedDataIfExists
{
    if ([[EDDCachingAgent sharedInstance] cacheExistsForSite:self.site.siteID forCacheType:EDDSalesCache]) {
        NSMutableDictionary *data = [[[EDDCachingAgent sharedInstance] fetchCacheForSite:self.site.siteID forCacheType:EDDSalesCache] copy];
        NSString *key = [NSString stringWithFormat:@"EDD_Site_%ld", (long) self.site.siteID];
        self.data = data[key];
    }
}

- (void)loadData:(UIRefreshControl *)refreshControl
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(queue, ^{
        [self.refreshControl beginRefreshing];
        
        EDDNetworkService *networkService = [EDDNetworkService sharedInstance];
        networkService.site = self.site;
        
        [networkService fetchSales:1 completionBlock:^(NSDictionary *sales) {
            _downloadComplete = YES;
            self.data = [sales mutableCopy];
            [self save];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
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
    if (_downloadComplete) {
        [[EDDCachingAgent sharedInstance] setCacheForSite:self.site.siteID forCacheType:EDDSalesCache data:self.data];
        [[EDDCachingAgent sharedInstance] saveCacheForSite:self.site.siteID forCacheType:EDDSalesCache];
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data[@"sales"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EDDSalesTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"salesCell"];
    
    if (cell == nil) {
        cell = [[EDDSalesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"salesCell"];
    }
    
    return cell;
}

- (void)statusBarTapped
{
    [self.tableView setContentOffset:CGPointZero animated:YES];
}

@end