//
//  EDDCustomerTableViewCell.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 10/18/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import "EDDCustomerTableViewCell.h"

@implementation EDDCustomerTableViewCell

- (void)setCustomer:(EDDCustomer *)customer {
    _customer = customer;
    
    [self refreshUserInterface];
}

- (void)refreshUserInterface {
    [self.gravatar setEmail:self.customer.email];
    
    [self.gravatar loadGravatar];
    
    self.emailLabel.text = self.customer.email;
}

@end
