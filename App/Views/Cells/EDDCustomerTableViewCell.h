//
//  EDDCustomerTableViewCell.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 10/18/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EDDCustomer.h"
#import "EDDGravatarImageView.h"

@interface EDDCustomerTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet EDDGravatarImageView *gravatar;

@property (nonatomic, weak) IBOutlet UILabel *emailLabel;

@property (nonatomic, strong) EDDCustomer *customer;

@end
