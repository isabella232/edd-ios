//
//  EDDSalesSearchViewController.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 7/1/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import "EDDBaseTableViewController.h"

#import "EDDSearchBar.h"

@interface EDDSalesSearchViewController : EDDBaseTableViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UIView *headerView;

@property (nonatomic, strong) IBOutlet EDDSearchBar *searchBar;

@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic, strong) NSString *searchTerm;

@property (nonatomic) NSInteger currentPage;

@property (nonatomic) NSInteger totalPages;

@property (nonatomic, strong) NSString *customerEmail;

- (id)initWithCustomerEmail:(NSString *)email;

@end
