//
//  EDDCustomersListViewController.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 10/18/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import "EDDCustomersListViewController.h"

#import "EDDCustomer.h"
#import "EDDCustomerDetailViewController.h"
#import "EDDCustomersSearchViewController.h"
#import "EDDCustomerTableViewCell.h"
#import "SVProgressHUD.h"
#import "UIColor+Helpers.h"
#import "UIView+EDDAdditions.h"

const int kCustomersLoadingCellTag = 1273;

@interface EDDCustomersListViewController ()

- (void)refresh:(id)sender;
- (void)reload:(id)sender;

@property (nonatomic, retain) NSMutableArray *customers;

@end

@implementation EDDCustomersListViewController

@synthesize customers = _customers;

#pragma mark - UIView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.customers = [NSMutableArray array];
    
    _currentPage = 0;
    _totalPages = 99;
    
    self.title = NSLocalizedString(@"Customers", nil);
    
    [self setupRightBarButtonItems];
    
    [self.tableView setBackgroundView:nil];
    [self.tableView setBackgroundColor:[UIColor colorWithHexString:@"#ededed"]];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"EDDCustomerTableViewCell" bundle:nil] forCellReuseIdentifier:@"EDDCustomerTableViewCell"];
	   
    [self reload:nil];
}

- (void)setupRightBarButtonItems {
    self.refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
    
    UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(search:)];
    
    self.navigationItem.rightBarButtonItems = @[ search, self.refresh ];
}

#pragma mark - API

- (void)refresh:(id)sender {
    _currentPage = 0;
    _totalPages = 99;
    
    self.customers = [NSMutableArray array];
    
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    [self.tableView reloadData];
}

- (void)reload:(id)sender {
    if (_currentPage == 0) return;
    
    [SVProgressHUD showWithStatus:@"Loading Customers..." maskType:SVProgressHUDMaskTypeClear];
    self.refresh.enabled = NO;
    
    [EDDCustomer globalCustomersWithPage:_currentPage andWithBlock:^(NSArray *customers, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
        } else {
            if ([customers count] != 10) {
                _totalPages = _currentPage;
            }
            
            for (EDDCustomer *customer in customers) {
                if (![self.customers containsObject:customer]) {
                    [self.customers addObject:customer];
                }
            }
            [self.tableView reloadData];
        }
        [SVProgressHUD dismiss];
        
        self.refresh.enabled = YES;
    }];
}

#pragma mark - Navigation

- (void)search:(id)sender {
    EDDCustomersSearchViewController *searchViewController = [[EDDCustomersSearchViewController alloc] init];
    [self.navigationController pushViewController:searchViewController animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_currentPage == 0) {
        return 1;
    }
    
    if (_currentPage < _totalPages) {
        return [self.customers count] + 1;
    }
    
    return [self.customers count];
}

- (UITableViewCell *)EDDCustomerTableViewCellForIndexPath:(NSIndexPath *)indexPath {
    EDDCustomerTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EDDCustomerTableViewCell"];
    
    EDDCustomer *customer = [self.customers objectAtIndex:indexPath.row];
    
    cell.customer = customer;
    
    return cell;
}

- (UITableViewCell *)loadingCell {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:nil];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]
                                                  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = cell.center;
    [cell addSubview:activityIndicator];
    
    [activityIndicator startAnimating];
    
    cell.tag = kCustomersLoadingCellTag;
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.customers.count) {
        return [self EDDCustomerTableViewCellForIndexPath:indexPath];
    } else {
        return [self loadingCell];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (cell.tag == kCustomersLoadingCellTag) {
        _currentPage++;
        [self reload:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EDDCustomer *customer = [self.customers objectAtIndex:indexPath.row];
    
    EDDCustomerDetailViewController *detailViewController = [[EDDCustomerDetailViewController alloc] initWithCustomer:customer];
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

@end
