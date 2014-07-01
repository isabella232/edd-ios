//
//  CommissionDetailViewController.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/1/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import "EDDBaseViewController.h"

#import "Commission.h"

@interface CommissionDetailViewController : EDDBaseViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, strong) Commission *commission;

- (id)initWithCommission:(Commission *)commission;

@end
