//
//  EDDSiteSwitchViewController.h
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 03/01/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EDDSiteSwitchViewControllerDelegate <NSObject>

@required
- (void)didSelectSite:(NSInteger *)siteID;

@end

@interface EDDSiteSwitchViewController : UIViewController

@property (nonatomic, weak) id <EDDSiteSwitchViewControllerDelegate>delegate;

@end