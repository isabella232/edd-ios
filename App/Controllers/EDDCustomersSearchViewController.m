//
//  EDDCustomersSearchViewController.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 10/18/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import "EDDCustomersSearchViewController.h"

@interface EDDCustomersSearchViewController ()

@end

@implementation EDDCustomersSearchViewController

- (id)init {
    if (self = [super init]) {        
        self.items = [NSMutableArray array];
        
        self.title = NSLocalizedString(@"Search Sales", nil);
    }
    return self;
}

@end
