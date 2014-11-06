//
//  ProductCell.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/17/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EDDProduct.h"

@interface ProductCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *earnings;
@property (weak, nonatomic) IBOutlet UILabel *sales;

@property (strong, nonatomic) EDDProduct *product;

- (void)initializeProduct:(EDDProduct *)product;

@end
