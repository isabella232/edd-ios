//
//  EDDCustomerDetailViewController.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 10/18/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import "EDDBaseTableViewController.h"

#import "EDDCUstomer.h"

@interface EDDCustomerDetailViewController : EDDBaseTableViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) EDDCustomer *customer;

- (id)initWithCustomer:(EDDCustomer *)customer;

@end
