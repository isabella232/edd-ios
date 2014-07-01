//
//  CommissionDetailViewController.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/1/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import "EDDBaseTableViewController.h"

#import "Commission.h"

@interface CommissionDetailViewController : EDDBaseTableViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) Commission *commission;

- (id)initWithCommission:(Commission *)commission;

@end
