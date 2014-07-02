//
//  AboutViewController.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/9/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "EDDBaseViewController.h"

#import "BButton.h"

@interface AboutViewController : EDDBaseViewController

@property (nonatomic, retain) IBOutlet UILabel *versionInfo;
@property (nonatomic, retain) IBOutlet BButton *eddButton;
@property (nonatomic, retain) IBOutlet BButton *ifButton;

- (IBAction)launchEddWebsite:(id)sender;
- (IBAction)launchIdleFusionWebsite:(id)sender;

@end
