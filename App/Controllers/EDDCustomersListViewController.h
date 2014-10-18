//
//  EDDCustomersListViewController.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 10/18/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import "EDDBaseTableViewController.h"

@interface EDDCustomersListViewController : EDDBaseTableViewController<UITableViewDelegate, UITableViewDataSource> {
    NSInteger _currentPage;
    NSInteger _totalPages;
}

@property (nonatomic, strong) UIBarButtonItem *refresh;

@end
