//
//  EDDViewController.m
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 25/12/2015.
//  Copyright © 2015 Easy Digital Downloads. All rights reserved.
//

#import "EDDViewController.h"
#import "Reachability.h"
#import "EDDAppDelegate.h"

#import "UIColor+EDDUIColorCategory.h"

@interface EDDViewController ()

@property (nonatomic, strong) Reachability *internetReachable;

@end

@implementation EDDViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    self.internetReachable = [Reachability reachabilityForInternetConnection];
    [self.internetReachable startNotifier];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)checkNetworkStatus:(NSNotification *)notice
{
    NetworkStatus internetStatus = [self.internetReachable currentReachabilityStatus];
    
    if (internetStatus == ReachableViaWiFi) {
        NSLog(@"internet works! :D");
    }
    
    if (internetStatus == NotReachable) {
        NSLog(@"internet broke! :(");
        [self showNoInternetMessage];
    }
}

- (void)showNoInternetMessage
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width - 20, 60)];
    label.backgroundColor = [UIColor EDDColorWithRed:59.0f green:64.0f blue:67.0f alpha:0.9f];
    label.text = @"Please check your network connection. Your site could also be down.";
    label.font = [UIFont boldSystemFontOfSize:15.0f];
    label.textColor = [UIColor whiteColor];
    [self.view addSubview:label];
}

@end