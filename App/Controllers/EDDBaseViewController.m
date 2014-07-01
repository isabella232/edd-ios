//
//  BaseViewController.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/9/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "EDDBaseViewController.h"

#import "EDDAnalytics.h"
#import "NVSlideMenuController.h"
#import "UIColor+Helpers.h"

@implementation EDDBaseViewController

#pragma mark - UIView

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.edgesForExtendedLayout = UIRectEdgeNone;
	
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"", nil) style:UIBarButtonItemStylePlain target:self action:nil];
    
    self.navigationItem.leftBarButtonItem = [self slideOutBarButton];
	[self.view setBackgroundColor:[UIColor colorWithHexString:@"#ededed"]];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[ARAnalytics pageView:[NSString stringWithFormat:@"%@", self.class]];
}

#pragma mark - Menu

- (UIImage *)listImage {
    return [UIImage imageNamed:@"list.png"];
}

- (UIBarButtonItem *)slideOutBarButton {
    return [[UIBarButtonItem alloc] initWithImage:[self listImage]
                                            style:UIBarButtonItemStyleBordered
                                           target:self
                                           action:@selector(slideOut:)];
}

#pragma mark - Event handlers

- (void)slideOut:(id)sender {
    [self.slideMenuController toggleMenuAnimated:self];
}

@end
