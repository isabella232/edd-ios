//
//  EDDSalesSearchViewController.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 7/1/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import "EDDSalesSearchViewController.h"

#import "Sale.h"
#import "SaleCell.h"
#import "SaleDetailViewController.h"
#import "SVProgressHUD.h"
#import "UIScrollView+EDDAdditions.h"

const int kSalesSearchLoadingCellTag = 1273;

static NSString *cellIdentifier = @"SaleCell";

@implementation EDDSalesSearchViewController

- (id)init {
	if (self = [super init]) {
		self.items = [NSMutableArray array];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = NSLocalizedString(@"Search Sales", nil);
    
    self.navigationItem.leftBarButtonItem = nil;
	
	[self.tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
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
    
    [Sale salesWithEmail:self.searchTerm page:self.currentPage block:^(NSArray *sales, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
        } else {
			if ([sales count] != PAGING_RETURN) {
				_totalPages = _currentPage;
			}
			
			for (Sale *sale in sales) {
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
    
	Sale *sale = [self.items objectAtIndex:indexPath.row];
	[cell initializeSale:sale];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	[self clearSearchUI];
	
	Sale *sale = [self.items objectAtIndex:indexPath.row];
	SaleDetailViewController *detailViewController = [[SaleDetailViewController alloc] initWithSale:sale];
	
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
