//
//  EDDMainViewController.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/9/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "EDDMainViewController.h"

#import "EDDCommission.h"
#import "EDDCommissionsListViewController.h"
#import "EDDAPIClient.h"
#import "EDDHelpers.h"
#import "EDDSlideMenuController.h"
#import "NSString+DateHelper.h"
#import "EDDSalesViewController.h"
#import "EDDSettingsHelper.h"
#import "EDDSetupViewController.h"
#import "SVProgressHUD.h"
#import "UIColor+Helpers.h"
#import "UIView+EDDAdditions.h"

@interface EDDMainViewController () {
    EDDSetupViewController *setupViewController;
    BOOL setupIsPresent;
}

@end

@implementation EDDMainViewController {
    
@private
    float currentMonthlyEarnings;
    float alltimeEarnings;
    float todaysEarnings;
}

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    [self setupNotifications];
    
    return self;
}

- (void)reload:(id)sender {
    [self setupSiteName];
    
    self.salesButton.hidden = [EDDSettingsHelper isCommissionOnlySite];
    
    [SVProgressHUD showWithStatus:@"Loading Data..." maskType:SVProgressHUDMaskTypeClear];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    if ([EDDSettingsHelper isCommissionOnlySite]) {
        [self loadCommissions];
    } else {
        [self loadEarningsReport];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top-brand"]];
    
    self.title = NSLocalizedString(@"Home", nil);
    
    [self.salesButton setType:BButtonTypePrimary];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload:)];
    
    [self.tableView setBackgroundView:nil];
    [self.tableView setBackgroundColor:[UIColor colorWithHexString:@"#ededed"]];
    
    self.tableView.tableFooterView = self.footerView;
    
    [self setupSiteName];
    
    if ([EDDSettingsHelper requiresSetup]) {
        //	if (YES) { // for testing
        [self showSetup];
        setupIsPresent = YES;
    } else {
        [self reload:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.salesButton.hidden = [EDDSettingsHelper isCommissionOnlySite];
}

- (void)setupSiteName {
    NSString *siteName = [EDDSettingsHelper getSiteName];
    self.siteName.text = siteName;
    self.siteName.hidden = [NSString isNullOrWhiteSpace:siteName];
}

- (void)loadEarningsReport {
    NSMutableDictionary *params = [EDDAPIClient defaultParams];
    
    [params setValue:@"stats" forKey:@"edd-api"];
    
    [params setValue:@"earnings" forKey:@"type"];
    
    [[EDDAPIClient sharedClient] getPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
        if ([JSON isKindOfClass:[NSArray class]]) { // Commissions
            currentMonthlyEarnings = 0.0f;
            
            alltimeEarnings = 0.0f;
            
            todaysEarnings = 0.0f;
        } else {
            NSDictionary *earningsFromResponse = [JSON valueForKeyPath:@"earnings"];
            
            currentMonthlyEarnings = [[earningsFromResponse objectForKey:@"current_month"] floatValue];
            
            alltimeEarnings = [[earningsFromResponse objectForKey:@"totals"] floatValue];
            
            todaysEarnings = [[earningsFromResponse objectForKey:@"today"] floatValue];
        }
        
        [params setValue:@"today" forKey:@"date"];
        
        [[EDDAPIClient sharedClient] getPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
            if ([JSON isKindOfClass:[NSArray class]]) { // Commissions
                
                todaysEarnings = 0.0f;
            } else {
                NSDictionary *earningsFromResponse = [JSON valueForKeyPath:@"earnings"];
            
                todaysEarnings = [[earningsFromResponse objectForKey:@"today"] floatValue];
            }
            
            self.navigationItem.rightBarButtonItem.enabled = YES;
            
            [self.tableView reloadData];
            
            [SVProgressHUD dismiss];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            
            [self.tableView reloadData];
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

- (void)loadCommissions {
    [SVProgressHUD showWithStatus:@"Loading Commissions..." maskType:SVProgressHUDMaskTypeClear];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [EDDCommission globalCommissionsWithBlock:^(NSArray *unpaid, NSArray *paid, float unpaidTotal, float paidTotal, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
        }
        
        self.unpaid = unpaid;
        self.paid = paid;
        self.unpaidTotal = unpaidTotal;
        self.paidTotal = paidTotal;
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [self.tableView reloadData];
        
        [SVProgressHUD dismiss];
    }];
}

- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(setupDismissalRequested:) name:@"SettingsInitialSetup" object: nil];
}

- (void)showSetup {
    setupViewController = [[EDDSetupViewController alloc] initForInitialSetup];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:setupViewController];
    
    nav.navigationBar.translucent = NO;
    
    if ([EDDHelpers isTablet]) {
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)setupDismissalRequested:(NSNotification *) notification {
    [self setupSiteName];
    [self dismissViewControllerAnimated:YES completion:nil];
    setupIsPresent = NO;
    [self reload:nil];
}

- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [EDDSettingsHelper isCommissionOnlySite] ? 3 : 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        
        cell.textLabel.text = [EDDSettingsHelper isCommissionOnlySite] ? @"Commissions" : @"Earnings";
        
        cell.textLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:20.0f];
        
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        
        return cell;
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];

    cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#009100"];
    
    float earnings = 0.0f;
    
    NSString *labelText = @"";
    
    if ([EDDSettingsHelper isCommissionOnlySite]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        switch (indexPath.row) {
            case 1:
                earnings = self.unpaidTotal;
                labelText = @"Unpaid Commissions:";
                break;
            case 2:
                earnings = self.paidTotal;
                labelText = @"Paid Commissions:";
                break;
        }
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        switch (indexPath.row) {
            case 1:
                earnings = todaysEarnings;
                labelText = @"Today:";
                break;
            case 2:
                earnings = currentMonthlyEarnings;
                labelText = @"Current Month:";
                break;
            case 3:
                earnings = alltimeEarnings;
                labelText = @"All-Time:";
                break;
        }
    }
    
    cell.textLabel.text = labelText;
    
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    [currencyFormatter setCurrencyCode:[EDDSettingsHelper getCurrency]];
    
    cell.detailTextLabel.text = [currencyFormatter stringFromNumber: [NSNumber numberWithFloat:earnings]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (![EDDSettingsHelper isCommissionOnlySite]) return;
    
    if (indexPath.row == 1 && self.unpaid.count == 0) return;
    
    if (indexPath.row == 2 && self.paid.count == 0) return;
    
    EDDCommissionsListViewController *commissionsListViewController = nil;
    
    if (indexPath.row == 1) { // unpaid
        commissionsListViewController = [[EDDCommissionsListViewController alloc] initWithUnpaidCommissions:self.unpaid];
    } else if (indexPath.row == 2) { // paid
        commissionsListViewController = [[EDDCommissionsListViewController alloc] initWithPaidCommissions:self.paid];
    }
    
    [self.navigationController pushViewController:commissionsListViewController animated:YES];
}

#pragma mark - IBActions

- (IBAction)salesButtonTapped:(id)sender {
    EDDSalesViewController *salesViewController = [[EDDSalesViewController alloc] init];
    [self.navigationController pushViewController:salesViewController animated:YES];
}

@end
