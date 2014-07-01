//
//  EDDBaseTableViewController.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 7/1/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import "EDDBaseTableViewController.h"

#import "UIView+EDDAdditions.h"

@implementation EDDBaseTableViewController

- (void)viewDidLoad {
	[super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[self ensureScrollIntegrity];
}

- (void)ensureScrollIntegrity {
    [self.view disableScrollsToTopPropertyOnMeAndAllSubviews];
	
    self.tableView.scrollsToTop = YES;
}

- (CGFloat)heightForCell:(UITableViewCell *)cell identifier:(NSString *)identifier indexPath:(NSIndexPath *)indexPath {
	if (!cell) {
		cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
	}
	
	[self configureCell:cell forRowAtIndexPath:indexPath];
	
	[cell layoutIfNeeded];
	
	CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
	height += 1.0f;
	return height;
}

- (void)configureCell:(id)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	
}

@end
