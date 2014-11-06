//
//  EDDSaleDetailViewController.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/16/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "EDDBaseTableViewController.h"

#import "EDDSale.h"

@interface EDDSaleDetailViewController : EDDBaseTableViewController<UITableViewDelegate, UITableViewDataSource>

- (id)initWithSale:(EDDSale *)sale;

@end
