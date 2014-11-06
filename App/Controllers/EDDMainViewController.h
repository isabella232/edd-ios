//
//  EDDMainViewController.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/9/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "EDDBaseTableViewController.h"

#import "BButton.h"

@interface EDDMainViewController : EDDBaseTableViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) IBOutlet BButton *salesButton;
@property (nonatomic, retain) IBOutlet UILabel *siteName;
@property (nonatomic, weak) IBOutlet UIView *footerView;

@property (nonatomic, strong) NSArray *unpaid;
@property (nonatomic, strong) NSArray *paid;
@property (nonatomic) float unpaidTotal;
@property (nonatomic) float paidTotal;

- (IBAction)salesButtonTapped:(id)sender;

- (void)reload:(id)sender;

@end
