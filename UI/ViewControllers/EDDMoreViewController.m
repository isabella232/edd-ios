//
//  EDDMoreViewController.m
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 25/12/2015.
//  Copyright © 2015 Easy Digital Downloads. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "EDDMoreViewController.h"
#import "EDDSite.h"
#import "EDDHeaderLabel.h"

@interface EDDMoreViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) EDDSite *site;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) EDDHeaderLabel *headerView;

@end

@implementation EDDMoreViewController

- (instancetype)initWithSite:(EDDSite *)site
{
    self = [super init];
    if (self) {
        self.site = site;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"More", @"");
    self.navigationItem.title = NSLocalizedString(@"More", @"");
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setupTableView];
    [self setupHeaderView];
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
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.bounces = YES;
    
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end