//
//  EDDSiteSwitchViewController.m
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 03/01/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

#import "EDDSiteSwitchViewController.h"
#import "EDDAppDelegate.h"
#import "EDDSites.h"
#import "EDDSite.h"
#import "EDDLaunchCell.h"
#import "KeychainItemWrapper.h"

@interface EDDSiteSwitchViewController () <UINavigationBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *sites;
@property (nonatomic) NSInteger currentSiteID;

@end

@implementation EDDSiteSwitchViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *sitesPath = [documentsDirectory stringByAppendingPathComponent: @"sites.eddsites"];
    EDDSites *sites = [NSKeyedUnarchiver unarchiveObjectWithFile:sitesPath];
    NSMutableArray *siteObjects = sites.sites;
    
    for (EDDSite *site in siteObjects) {
        [siteObjects addObject:site];
    }
    
    self.currentSiteID = [[EDDAppDelegate sharedEDDAppDelegate] getDefaultSiteID];
    
    self.sites = siteObjects;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurEffectView setFrame:self.view.bounds];
    
    [self.view addSubview:blurEffectView];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapGestureAction:)];
    gestureRecognizer.numberOfTapsRequired = 1;
    gestureRecognizer.cancelsTouchesInView = YES;
    [self.view addGestureRecognizer:gestureRecognizer];
    
    self.tapGestureRecognizer = gestureRecognizer;
    
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    navigationBar.delegate = self;
    navigationBar.translucent = YES;
    navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"Switch Site", @"")];
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed:)];
    UIBarButtonItem *addBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSiteButtonPressed:)];
    navigationItem.leftBarButtonItem = cancelBarButtonItem;
    navigationItem.rightBarButtonItem = addBarButtonItem;
    navigationBar.items = [NSArray arrayWithObjects:navigationItem, nil];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navigationBar.frame.size.height,self.view.frame.size.width, self.view.frame.size.height - navigationBar.frame.size.height)];
    tableView.scrollEnabled = YES;
    tableView.showsVerticalScrollIndicator = YES;
    tableView.userInteractionEnabled = YES;
    tableView.bounces = YES;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:0.3f];
    tableView.tableFooterView = [UIView new];
    self.tableView = tableView;
    [self.tableView registerClass:[EDDLaunchCell class] forCellReuseIdentifier:@"pickerCell"];
    
    [self.view addSubview:navigationBar];
    [self.view addSubview:self.tableView];
}

- (void)cancelButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addSiteButtonPressed:(id)sender
{
    
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)backgroundTapGestureAction:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _sites.count;
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"pickerCell";
    EDDLaunchCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[EDDLaunchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    EDDSite *site = [_sites objectAtIndex:indexPath.row];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = site.siteName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end