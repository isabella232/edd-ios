//
//  SalesViewController.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/8/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "BaseViewController.h"

@interface SalesViewController : BaseViewController<UITableViewDelegate, UITableViewDataSource> {	
    NSInteger _currentPage;
    NSInteger _totalPages;
}

@end
