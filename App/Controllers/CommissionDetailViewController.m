//
//  CommissionDetailViewController.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/1/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import "CommissionDetailViewController.h"

#import "SettingsHelper.h"
#import "SVProgressHUD.h"
#import "UIColor+Helpers.h"
#import "UIView+ViewHelper.h"

@implementation CommissionDetailViewController

- (id)initWithCommission:(Commission *)commission {
	if (self = [super init]) {
		self.commission = commission;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"Commission Detail", nil);
	
	self.navigationItem.leftBarButtonItem = nil;
	
    [self.tableView setBackgroundView:nil];
	[self.tableView setBackgroundColor:[UIColor colorWithHexString:@"#ededed"]];
	
    [self.view disableScrollsToTopPropertyOnMeAndAllSubviews];
    self.tableView.scrollsToTop = YES;
	
	[self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
	cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#009100"];
	
    // Configure the cell...
	
	switch (indexPath.row) {
		case 0: {
			cell.textLabel.text = @"Item:";
			cell.detailTextLabel.text = self.commission.item;
			cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#000000"];
		}
			break;
		case 1: {
			cell.textLabel.text = @"Currency:";
			cell.detailTextLabel.text = self.commission.currency;
			cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#000000"];
		}
			break;
		case 2: {
			NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
			[currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
			[currencyFormatter setCurrencyCode:[SettingsHelper getCurrency]];
			
			cell.textLabel.text = @"Amount:";
			cell.detailTextLabel.text = [currencyFormatter stringFromNumber:[NSNumber numberWithFloat:self.commission.amount]];
			cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#009100"];
		}
			break;
		case 3: {
			NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
			[numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
			[numberFormatter setMinimumFractionDigits:2];
			
			cell.textLabel.text = @"Rate:";
			
			float rate = self.commission.rate / 100;			
			cell.detailTextLabel.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:rate]];
			cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#000000"];
		}
			break;
	}
		
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	return [[UIView alloc] init];
}

@end
