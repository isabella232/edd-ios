//
//  EDDEditDashboardViewController.m
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 03/01/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

#import "EDDEditDashboardViewController.h"

@interface EDDEditDashboardViewController () <UINavigationBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) EDDSite *site;
@property (nonatomic, strong) NSMutableArray *dashboardOrder;

@end

@implementation EDDEditDashboardViewController

- (instancetype)initWithSite:(EDDSite *)site;
{
    self = [super init];
    if (self) {
        self.site = site;
        self.dashboardOrder = [site.dashboardOrder copy];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurEffectView setFrame:self.view.bounds];
    
    [self.view addSubview:blurEffectView];
    
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    navigationBar.delegate = self;
    navigationBar.translucent = YES;
    navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"Edit Dashboard", @"")];
    UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"") style:UIBarButtonItemStyleDone target:self action:@selector(cancelButtonPressed:)];
    navigationItem.rightBarButtonItem = doneBarButtonItem;
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
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"orderCell"];
    tableView.editing = YES;
    self.tableView = tableView;
    
    [self.view addSubview:navigationBar];
    [self.view addSubview:self.tableView];
    
    NSLog(@"%@", self.site.dashboardOrder);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancelButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dashboardOrder.count;
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"orderCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    int currentValue = [(NSNumber *)[_dashboardOrder objectAtIndex:indexPath.row] intValue];
    
    NSString *cellText;
    
    switch (currentValue) {
        case 0:
            cellText = @"Sales";
            break;
        case 1:
            cellText = @"Earnings";
            break;
        case 2:
            cellText = @"Commissions";
            break;
        case 3:
            cellText = @"Store Commissions";
            break;
        case 4:
            cellText = @"Reviews";
            break;
        default:
            break;
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = cellText;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSString *stringToMove = [_dashboardOrder objectAtIndex:sourceIndexPath.row];
    [_dashboardOrder removeObjectAtIndex:sourceIndexPath.row];
    [_dashboardOrder insertObject:stringToMove atIndex:destinationIndexPath.row];
    
}

@end