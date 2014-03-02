//
//  CommissionsViewController.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/1/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import "CommissionsViewController.h"

#import "Commission.h"
#import "CommissionsListViewController.h"
#import "SettingsHelper.h"
#import "SVProgressHUD.h"
#import "UIColor+Helpers.h"
#import "UIView+ViewHelper.h"

@implementation CommissionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"Commissions", nil);
	
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload:)];
	
	[self.tableView setBackgroundView:nil];
	[self.tableView setBackgroundColor:[UIColor colorWithHexString:@"#ededed"]];
	
    [self.view disableScrollsToTopPropertyOnMeAndAllSubviews];
    self.tableView.scrollsToTop = YES;
	
	[self reload:nil];
}

- (void)reload:(id)sender {
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
		
		[self.tableView reloadData];

		[SVProgressHUD dismiss];
        self.navigationItem.rightBarButtonItem.enabled = YES;
	}];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
	cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#009100"];
    
    // Configure the cell...
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	float earnings = 0.0f;
	
	switch (indexPath.row) {
		case 0:
			earnings = self.unpaidTotal;
			break;
		case 1:
			earnings = self.paidTotal;
			break;
	}
	
	NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
	[currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[currencyFormatter setCurrencyCode:[SettingsHelper getCurrency]];
	
	cell.textLabel.text = indexPath.row == 0 ? @"Unpaid Commissions:" : @"Paid Commissions";
	cell.detailTextLabel.text = [currencyFormatter stringFromNumber: [NSNumber numberWithFloat:earnings]];
	
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
		
	CommissionsListViewController *commissionsListViewController = nil;
	
	if (indexPath.row == 0) { // unpaid
		commissionsListViewController = [[CommissionsListViewController alloc] initWithUnpaidCommissions:self.unpaid];
	} else if (indexPath.row == 1) { // paid
		commissionsListViewController = [[CommissionsListViewController alloc] initWithPaidCommissions:self.paid];
	}
	[self.navigationController pushViewController:commissionsListViewController animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	return [[UIView alloc] init];
}

@end
