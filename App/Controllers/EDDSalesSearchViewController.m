//
//  EDDSalesSearchViewController.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 7/1/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import "EDDSalesSearchViewController.h"

#import "EDDSale.h"
#import "EDDSaleDetailViewController.h"
#import "SaleCell.h"
#import "SVProgressHUD.h"
#import "UIScrollView+EDDAdditions.h"
#import "UIColor+Helpers.h"

const int kSalesSearchLoadingCellTag = 1273;

static NSString *cellIdentifier = @"SaleCell";

@implementation EDDSalesSearchViewController

- (id)init {
	if (self = [super init]) {
        self.customerEmail = nil;
        
		self.items = [NSMutableArray array];
        
        self.title = NSLocalizedString(@"Search Sales", nil);
	}
	return self;
}

- (id)initWithCustomerEmail:(NSString *)email {
    if (self = [self init]) {
        self.customerEmail = email;
        
        self.title = NSLocalizedString(@"Purchase History", nil);
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = nil;
    
    [self.tableView setBackgroundView:nil];
    [self.tableView setBackgroundColor:[UIColor colorWithHexString:@"#ededed"]];
	
	[self.tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.customerEmail != nil) {
        [self loadData];
    }
}

- (void)setupInfiniteScrolling {
	__weak EDDSalesSearchViewController *weakSelf = self;
	
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
        if (self.customerEmail == nil) {
            return;
        }
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
        searchTerm = self.customerEmail;
    }
    
    [EDDSale salesWithEmail:searchTerm page:self.currentPage block:^(NSArray *sales, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
        } else {
			if ([sales count] != PAGING_RETURN) {
				_totalPages = _currentPage;
			}
			
			for (EDDSale *sale in sales) {
				if (![self.items containsObject:sale]) {
					[self.items addObject:sale];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self saleCellForIndexPath:indexPath];
}

- (UITableViewCell *)saleCellForIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SaleCell";
    SaleCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
    if (!cell) {
        cell = [[SaleCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                               reuseIdentifier:cellIdentifier];
    }
    
	EDDSale *sale = [self.items objectAtIndex:indexPath.row];
	[cell initializeSale:sale];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	[self clearSearchUI];
	
	EDDSale *sale = [self.items objectAtIndex:indexPath.row];
	EDDSaleDetailViewController *detailViewController = [[EDDSaleDetailViewController alloc] initWithSale:sale];
	
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return self.customerEmail == nil ? 44.0f : 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return self.customerEmail == nil ? self.headerView : nil;
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
