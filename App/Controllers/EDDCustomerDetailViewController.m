//
//  EDDCustomerDetailViewController.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 10/18/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import "EDDCustomerDetailViewController.h"

#import "EDDCustomersSearchViewController.h"
#import "EDDCustomerDetailTableViewCell.h"
#import "EDDSalesSearchViewController.h"
#import "EDDSettingsHelper.h"
#import "NSString+DateHelper.h"
#import "UIColor+Helpers.h"
#import "UIView+EDDAdditions.h"

@implementation EDDCustomerDetailViewController

- (id)initWithCustomer:(EDDCustomer *)customer {
    if (self = [super init]) {
        self.customer = customer;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.customerNameLabel.text = self.customer.email;
    
    [self.gravatar setEmail:self.customer.email];
    
    [self.gravatar loadGravatar];
    
    self.tableView.tableHeaderView = self.headerView;
    
    self.navigationItem.leftBarButtonItem = nil;
    
    [self.tableView setBackgroundView:nil];
    [self.tableView setBackgroundColor:[UIColor colorWithHexString:@"#ededed"]];
    
    self.title = NSLocalizedString(@"Customer Detail", nil);
    
    [self.tableView registerNib:[UINib nibWithNibName:@"EDDCustomerDetailTableViewCell" bundle:nil] forCellReuseIdentifier:@"EDDCustomerDetailTableViewCell"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 5 : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    
    cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#000000"];
    
    if (indexPath.section == 1) {
        cell.textLabel.text = @"View Customer's Purchase History";
        cell.detailTextLabel.text = @"";
    } else {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Name:";
            
            cell.detailTextLabel.text = self.customer.displayName;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Customer ID:";
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.customer.customerID];
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"WordPress ID:";
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.customer.wordpressID];
            
        } else if (indexPath.row == 3) {
            cell.textLabel.text = @"Total Purchases:";
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.customer.totalPurchases];
        } else if (indexPath.row == 4) {
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [formatter setCurrencyCode:[EDDSettingsHelper getCurrency]];
            
            cell.textLabel.text = @"Total Spent:";
            
            cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#009100"];
            
            cell.detailTextLabel.text = [formatter stringFromNumber:[NSNumber numberWithFloat:self.customer.totalSpent]];
        }
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section == 0 ? @"Details" : @"";
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        EDDSalesSearchViewController *searchViewController = [[EDDSalesSearchViewController alloc] initWithCustomerEmail:self.customer.email];
        
        [self.navigationController pushViewController:searchViewController animated:YES];
    }
}

@end
