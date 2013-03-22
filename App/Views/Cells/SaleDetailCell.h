//
//  SaleDetailCell.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/19/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SaleDetailCell : UITableViewCell

@property (weak,nonatomic) IBOutlet UILabel *name;
@property (weak,nonatomic) IBOutlet UILabel *price;

@end
