//
//  EDDStoreCommissionsListViewController.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 10/25/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import "EDDStoreCommissionsListViewController.h"

#import "EDDCommission.h"
#import "EDDCommissionDetailViewController.h"
#import "EDDSettingsHelper.h"
#import "SVProgressHUD.h"
#import "UIColor+Helpers.h"
#import "UIView+EDDAdditions.h"

const int kCommissionsLoadingCellTag = 122323;

@interface EDDStoreCommissionsListViewController ()

- (void)refresh:(id)sender;
- (void)reload:(id)sender;

@end

@implementation EDDStoreCommissionsListViewController

#pragma mark - UIView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.commissions = [NSMutableArray array];
    
    _currentPage = 0;
    _totalPages = 99;
    
    self.title = NSLocalizedString(@"Commissions", nil);
    
    [self setupRightBarButtonItems];
    
    [self.tableView setBackgroundView:nil];
    
    [self.tableView setBackgroundColor:[UIColor colorWithHexString:@"#ededed"]];
	   
    [self reload:nil];
}

- (void)setupRightBarButtonItems {
    self.refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
    
    self.navigationItem.rightBarButtonItems = @[ self.refresh ];
}

#pragma mark - API

- (void)refresh:(id)sender {
    _currentPage = 0;
    
    _totalPages = 99;
    
    self.commissions = [NSMutableArray array];
    
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    
    [self.tableView reloadData];
}

- (void)reload:(id)sender {
    if (_currentPage == 0) return;
    
    [SVProgressHUD showWithStatus:@"Loading Commissions..." maskType:SVProgressHUDMaskTypeClear];
    self.refresh.enabled = NO;
    
    [EDDCommission globalStoreCommissions:_currentPage block:^(NSArray *commissions, float totalUnpaid, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
        } else {
            if ([commissions count] != PAGING_RETURN) {
                _totalPages = _currentPage;
            }
            
            for (EDDCommission *commission in commissions) {
                if (![self.commissions containsObject:commission]) {
                    [self.commissions addObject:commission];
                }
            }
            
            self.totalUnpaid = totalUnpaid;
            
            [self.tableView reloadData];
        }
        [SVProgressHUD dismiss];
        self.refresh.enabled = YES;
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 1;
    
    if (_currentPage == 0) {
        return 1;
    }
    
    if (_currentPage < _totalPages) {
        return [self.commissions count] + 1;
    }
    
    return [self.commissions count];
}

- (UITableViewCell *)saleCellForIndexPath:(NSIndexPath *)indexPath {
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

- (UITableViewCell *)loadingCell {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:nil];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]
                                                  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    CGPoint viewCenter = self.view.center;
    
    CGPoint cellCenter = cell.center;
    
    cellCenter.x = viewCenter.x;
    
    activityIndicator.center = cellCenter;
    
    [cell addSubview:activityIndicator];
    
    [activityIndicator startAnimating];
    
    cell.tag = kCommissionsLoadingCellTag;
    
    return cell;
}

- (UITableViewCell *)totalUnpaidCommissionCell {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UnpaidCommissionCell"];
    
    cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#009100"];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    [currencyFormatter setCurrencyCode:[EDDSettingsHelper getCurrency]];
    
    cell.textLabel.text = @"Total Unpaid:";
    
    cell.detailTextLabel.text = [currencyFormatter stringFromNumber: [NSNumber numberWithFloat:self.totalUnpaid]];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [self totalUnpaidCommissionCell];
    }
    
    if (indexPath.row < self.commissions.count) {
        return [self saleCellForIndexPath:indexPath];
    } else {
        return [self loadingCell];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (cell.tag == kCommissionsLoadingCellTag) {
        _currentPage++;
        
        [self reload:nil];
    }
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
