//
//  CommissionsViewController.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/1/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import "EDDBaseViewController.h"

@interface CommissionsViewController : EDDBaseViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *unpaid;
@property (nonatomic, strong) NSArray *paid;
@property (nonatomic) float unpaidTotal;
@property (nonatomic) float paidTotal;

- (void)reload:(id)sender;

@end
