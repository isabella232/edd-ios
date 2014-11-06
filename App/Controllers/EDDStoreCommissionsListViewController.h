//
//  EDDStoreCommissionsListViewController.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 10/25/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import "EDDBaseTableViewController.h"

@interface EDDStoreCommissionsListViewController : EDDBaseTableViewController<UITableViewDelegate, UITableViewDataSource> {
    NSInteger _currentPage;
    NSInteger _totalPages;
}

@property (nonatomic, strong) UIBarButtonItem *refresh;

@property (nonatomic, strong) NSMutableArray *commissions;

@property (nonatomic) float totalUnpaid;

@end
