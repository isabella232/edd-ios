//
//  EDDCommissionDetailViewController.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/1/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import "EDDBaseTableViewController.h"

#import "EDDCommission.h"

@interface EDDCommissionDetailViewController : EDDBaseTableViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) EDDCommission *commission;

- (id)initWithCommission:(EDDCommission *)commission;

@end
