//
//  EDDCommissionsListViewController.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/1/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import "EDDCommissionsListViewController.h"

#import "EDDCommission.h"
#import "EDDCommissionDetailViewController.h"
#import "EDDSettingsHelper.h"
#import "SVProgressHUD.h"
#import "UIColor+Helpers.h"
#import "UIView+EDDAdditions.h"

@implementation EDDCommissionsListViewController

- (id)initWithUnpaidCommissions:(NSArray *)commissions {
	if (self = [super init]) {
		self.commissions = commissions;
		self.isUnpaid = YES;
	}
	return self;
}

- (id)initWithPaidCommissions:(NSArray *)commissions {
	if (self = [super init]) {
		self.commissions = commissions;
		self.isUnpaid = NO;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = self.isUnpaid ? NSLocalizedString(@"Unpaid Commissions", nil) : NSLocalizedString(@"Paid Commissions", nil);
	
	self.navigationItem.leftBarButtonItem = nil;
	
    [self.tableView setBackgroundView:nil];
	[self.tableView setBackgroundColor:[UIColor colorWithHexString:@"#ededed"]];	
	
	[self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.commissions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
	cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#009100"];
	
	EDDCommission *commission = [self.commissions objectAtIndex:indexPath.row];
    
    // Configure the cell...
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
	[currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[currencyFormatter setCurrencyCode:[EDDSettingsHelper getCurrency]];
	
	cell.textLabel.text = commission.item;
	cell.detailTextLabel.text = [currencyFormatter stringFromNumber: [NSNumber numberWithFloat:commission.amount]];
	
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	EDDCommission *commission = [self.commissions objectAtIndex:indexPath.row];
	EDDCommissionDetailViewController *commissionDetailViewController = [[EDDCommissionDetailViewController alloc] initWithCommission:commission];
	[self.navigationController pushViewController:commissionDetailViewController animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	return [[UIView alloc] init];
}

@end
