//
//  MainViewController.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/9/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "BaseViewController.h"

#import "BButton.h"

@interface MainViewController : BaseViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet BButton *salesButton;
@property (nonatomic, retain) IBOutlet UILabel *siteName;
@property (nonatomic, weak) IBOutlet UIView *footerView;

- (IBAction)salesButtonTapped:(id)sender;

- (void)reload:(id)sender;

@end
