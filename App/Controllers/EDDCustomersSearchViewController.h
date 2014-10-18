//
//  EDDCustomersSearchViewController.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 10/18/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import "EDDBaseTableViewController.h"

#import "EDDCustomerTableViewCell.h"
#import "EDDSearchBar.h"

@interface EDDCustomersSearchViewController : EDDBaseTableViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UIView *headerView;

@property (nonatomic, strong) IBOutlet EDDSearchBar *searchBar;

@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic, strong) NSString *searchTerm;

@property (nonatomic) NSInteger currentPage;

@property (nonatomic) NSInteger totalPages;

@property (nonatomic, strong) EDDCustomerTableViewCell *customerCell;

@end
