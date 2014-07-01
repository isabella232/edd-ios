//
//  MainViewController.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/9/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "MainViewController.h"

#import "Commission.h"
#import "CommissionsListViewController.h"
#import "EDDAPIClient.h"
#import "EDDSlideMenuController.h"
#import "NSString+DateHelper.h"
#import "SettingsHelper.h"
#import "SetupViewController.h"
#import "SVProgressHUD.h"
#import "UIColor+Helpers.h"
#import "UIView+ViewHelper.h"

@interface MainViewController () {
	SetupViewController *setupViewController;
	BOOL setupIsPresent;
}

@end

@implementation MainViewController {
	
@private
	float currentMonthlyEarnings;
	float alltimeEarnings;
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
	
	self.salesButton.hidden = [SettingsHelper isCommissionOnlySite];
	
	[SVProgressHUD showWithStatus:@"Loading Data..." maskType:SVProgressHUDMaskTypeClear];
    self.navigationItem.rightBarButtonItem.enabled = NO;
	
	if ([SettingsHelper isCommissionOnlySite]) {
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
	
    [self.view disableScrollsToTopPropertyOnMeAndAllSubviews];
    self.tableView.scrollsToTop = YES;
	
	self.tableView.tableFooterView = self.footerView;
	
	[self setupSiteName];
	
	if ([SettingsHelper requiresSetup]) {
		//	if (YES) { // for testing
		[self showSetup];
		setupIsPresent = YES;
	} else {
		[self reload:nil];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	self.salesButton.hidden = [SettingsHelper isCommissionOnlySite];
}

- (void)setupSiteName {
	NSString *siteName = [SettingsHelper getSiteName];
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
		} else {
			NSDictionary *earningsFromResponse = [JSON valueForKeyPath:@"earnings"];
			currentMonthlyEarnings = [[earningsFromResponse objectForKey:@"current_month"] floatValue];
			alltimeEarnings = [[earningsFromResponse objectForKey:@"totals"] floatValue];
		}
		
		self.navigationItem.rightBarButtonItem.enabled = YES;
		[self.tableView reloadData];
		[SVProgressHUD dismiss];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		self.navigationItem.rightBarButtonItem.enabled = YES;
		[SVProgressHUD showErrorWithStatus:error.localizedDescription];
	}];
}

- (void)loadCommissions {
	[SVProgressHUD showWithStatus:@"Loading Commissions..." maskType:SVProgressHUDMaskTypeClear];
    self.navigationItem.rightBarButtonItem.enabled = NO;
	
	[Commission globalCommissionsWithBlock:^(NSArray *unpaid, NSArray *paid, float unpaidTotal, float paidTotal, NSError *error) {
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
	setupViewController = [[SetupViewController alloc] initForInitialSetup];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:setupViewController];
	nav.navigationBar.translucent = NO;
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
	return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0) {
		UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
		cell.textLabel.text = [SettingsHelper isCommissionOnlySite] ? @"Commissions" : @"Earnings";
		cell.textLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:20.0f];
		cell.textLabel.textAlignment = NSTextAlignmentCenter;
		
		return cell;
	}
	
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
	cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#009100"];
    
    // Configure the cell...
	float earnings = 0.0f;
	
	if ([SettingsHelper isCommissionOnlySite]) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		switch (indexPath.row) {
			case 1:
				earnings = self.unpaidTotal;
				break;
			case 2:
				earnings = self.paidTotal;
				break;
		}
		
		cell.textLabel.text = indexPath.row == 1 ? @"Unpaid Commissions:" : @"Paid Commissions";
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
		
		switch (indexPath.row) {
			case 1:
				earnings = currentMonthlyEarnings;
				break;
			case 2:
				earnings = alltimeEarnings;
				break;
		}
		
		cell.textLabel.text = indexPath.row == 1 ? @"Current Month:" : @"All-Time:";
	}
	
	NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
	[currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[currencyFormatter setCurrencyCode:[SettingsHelper getCurrency]];
	
	cell.detailTextLabel.text = [currencyFormatter stringFromNumber: [NSNumber numberWithFloat:earnings]];
	
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if ([SettingsHelper isCommissionOnlySite]) {
		if (indexPath.row == 1 && self.unpaid.count == 0) return;
		if (indexPath.row == 2 && self.paid.count == 0) return;
		
		CommissionsListViewController *commissionsListViewController = nil;
		
		if (indexPath.row == 1) { // unpaid
			commissionsListViewController = [[CommissionsListViewController alloc] initWithUnpaidCommissions:self.unpaid];
		} else if (indexPath.row == 2) { // paid
			commissionsListViewController = [[CommissionsListViewController alloc] initWithPaidCommissions:self.paid];
		}
		[self.navigationController pushViewController:commissionsListViewController animated:YES];
	}	
}

#pragma mark - IBActions

- (IBAction)salesButtonTapped:(id)sender {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ShowRecentSales" object:self];
}

@end
