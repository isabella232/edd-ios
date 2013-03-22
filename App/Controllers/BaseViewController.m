//
//  BaseViewController.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/9/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "BaseViewController.h"
#import "NVSlideMenuController.h"
#import "UIColor+Helpers.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (UIImage *)listImage {
    return [UIImage imageNamed:@"list.png"];
}

- (UIBarButtonItem *)slideOutBarButton {
    return [[UIBarButtonItem alloc] initWithImage:[self listImage]
                                            style:UIBarButtonItemStyleBordered
                                           target:self
                                           action:@selector(slideOut:)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [self slideOutBarButton];
	[self.view setBackgroundColor:[UIColor colorWithHexString:@"#ededed"]];
}

#pragma mark - Event handlers

- (void)slideOut:(id)sender {
    [self.slideMenuController toggleMenuAnimated:self];
}

@end
