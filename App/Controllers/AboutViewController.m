//
//  AboutViewController.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/9/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@property (nonatomic, retain) IBOutlet UILabel *versionInfo;
@property (nonatomic, retain) IBOutlet UIButton *eddButton;
@property (nonatomic, retain) IBOutlet UIButton *ifButton;

- (IBAction)launchEddWebsite:(id)sender;
- (IBAction)launchIdleFusionWebsite:(id)sender;

@end

@implementation AboutViewController

- (void)viewDidLoad {
	[super viewDidLoad];	
    
    self.title = NSLocalizedString(@"About", nil);
	
	
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
