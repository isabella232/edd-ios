//
//  EDDBaseTableViewController.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 7/1/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import "EDDBaseViewController.h"

@interface EDDBaseTableViewController : EDDBaseViewController

@property (nonatomic, weak) IBOutlet UITableView *tableView;

- (void)ensureScrollIntegrity;

- (CGFloat)heightForCell:(UITableViewCell *)cell identifier:(NSString *)identifier indexPath:(NSIndexPath *)indexPath;

- (void)configureCell:(id)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

@end
