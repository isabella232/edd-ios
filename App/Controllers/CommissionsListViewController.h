//
//  CommissionsListViewController.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/1/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import "BaseViewController.h"

@interface CommissionsListViewController : BaseViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *commissions;
@property (nonatomic) float total;
@property (nonatomic) BOOL isUnpaid;

- (id)initWithUnpaidCommissions:(NSArray *)commissions;

- (id)initWithPaidCommissions:(NSArray *)commissions;

@end
