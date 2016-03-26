//
//  EDDSiteController.h
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 26/08/2015.
//  Copyright © 2015 Easy Digital Downloads. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EDDSite.h"

@interface EDDSiteController : UITabBarController <UITabBarControllerDelegate>

- (instancetype)initWithSite:(EDDSite *)site;

@end