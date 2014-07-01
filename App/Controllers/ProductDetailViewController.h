//
//  ProductDetailViewController.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/16/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "EDDBaseTableViewController.h"

#import "Product.h"

@interface ProductDetailViewController : EDDBaseTableViewController<UITableViewDelegate, UITableViewDataSource>

- (id)initWithProduct:(Product *)product;

@end
