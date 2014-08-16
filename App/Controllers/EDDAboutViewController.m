//
//  EDDAboutViewController.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/9/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "EDDAboutViewController.h"

@implementation EDDAboutViewController

- (void)viewDidLoad {
	[super viewDidLoad];	
    
    self.title = NSLocalizedString(@"About", nil);
	
	[self.eddButton setType:BButtonTypePrimary];
	[self.ifButton setType:BButtonTypePrimary];
	
    NSString* buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	self.versionInfo.text = [NSString stringWithFormat:@"Current Version: %@", buildNumber];
}

- (IBAction)launchEddWebsite:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://easydigitaldownloads.com"]];
}

- (IBAction)launchIdleFusionWebsite:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://idlefusion.com"]];
}

@end
