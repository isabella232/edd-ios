//
//  EDDCustomersSearchViewController.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 10/18/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import "EDDCustomersSearchViewController.h"

#import "EDDCustomer.h"
#import "EDDCustomerDetailViewController.h"
#import "SVProgressHUD.h"
#import "UIScrollView+EDDAdditions.h"

static NSString *cellIdentifier = @"EDDCustomerTableViewCell";

@implementation EDDCustomersSearchViewController

- (id)init {
    if (self = [super init]) {
        self.items = [NSMutableArray array];
        
        self.title = NSLocalizedString(@"Search Customers", nil);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = nil;
    
    [self.tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
}

- (void)setupInfiniteScrolling {
    __weak EDDCustomersSearchViewController *weakSelf = self;
    
    [self.tableView edd_addInfiniteScrollingWithActionHandler:^{
        [weakSelf incrementPage];
        [weakSelf loadDataPaged];
    }];
}

- (void)incrementPage {
    self.currentPage++;
}

- (void)loadDataPaged {
    if (self.currentPage == 0) return;
    
    if (self.currentPage > self.totalPages) return;
    
    [self loadSearchResults];
}

- (void)loadData {
    if (self.searchTerm == nil || [self.searchTerm isEqualToString:@""]) {
        return;
    }
    
    self.currentPage = 1;
    self.totalPages = 10;
    
    self.items = [NSMutableArray array];
    [self.tableView reloadData];
    
    [self loadSearchResults];
}

- (void)loadSearchResults {
    [SVProgressHUD showWithStatus:@"Searching..." maskType:SVProgressHUDMaskTypeClear];
    
    NSString *searchTerm = self.searchTerm;
    
    if (searchTerm == nil || [searchTerm isEqualToString:@""]) {
        return;
    }
    
    [EDDCustomer customersWithEmail:searchTerm page:self.currentPage block:^(NSArray *customers, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
        } else {
            if ([customers count] != 10) {
                _totalPages = _currentPage;
            }
            
            for (EDDCustomer *customer in customers) {
                if (![self.items containsObject:customer]) {
                    [self.items addObject:customer];
                }
            }
            
            [self.tableView reloadData];
        }
        [SVProgressHUD dismiss];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}


- (UITableViewCell *)EDDCustomerTableViewCellForIndexPath:(NSIndexPath *)indexPath {
    EDDCustomerTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EDDCustomerTableViewCell"];
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self EDDCustomerTableViewCellForIndexPath:indexPath];
}

- (void)configureCell:(id)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[EDDCustomerTableViewCell class]]) {
        EDDCustomerTableViewCell *customerCell = (EDDCustomerTableViewCell *)cell;
        
        EDDCustomer *customer = [self.items objectAtIndex:indexPath.row];
        
        customerCell.customer = customer;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = [self heightForCell:self.customerCell identifier:@"EDDCustomerTableViewCell" indexPath:indexPath];
    
    CGFloat minHeight = [EDDCustomerTableViewCell minHeight];
    
    if (height < minHeight) {
        height = minHeight;
    }
    
    return height;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    [self clearSearchUI];
    
    EDDCustomer *customer = [self.items objectAtIndex:indexPath.row];
    
    EDDCustomerDetailViewController *detailViewController = [[EDDCustomerDetailViewController alloc] initWithCustomer:customer];
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.headerView;
}

#pragma mark UISearchDisplayDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(stopSearch:)];
    
    self.navigationItem.rightBarButtonItem = cancelButton;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.searchTerm = searchBar.text;
    
    [self loadData];
    
    [self clearSearchUI];
}

- (void)stopSearch:(id)sender {
    [self clearSearchUI];
}

- (void)clearSearchUI {
    [self.searchBar resignFirstResponder];
    
    self.navigationItem.rightBarButtonItem = nil;
}

@end
