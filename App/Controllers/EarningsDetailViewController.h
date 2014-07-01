//
//  EarningsDetailViewController.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/19/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "EDDBaseTableViewController.h"

@interface EarningsDetailViewController : EDDBaseTableViewController<UITableViewDelegate, UITableViewDataSource>

- (id)initWithRange:(NSString *)range;

@end
