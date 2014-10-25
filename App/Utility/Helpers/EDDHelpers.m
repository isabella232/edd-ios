//
//  EDDHelpers.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 10/25/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import "EDDHelpers.h"

@implementation EDDHelpers

+ (BOOL)isHandset {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
}

+ (BOOL)isTablet {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

+ (BOOL)isSimulator {
    return (TARGET_IPHONE_SIMULATOR);
}

@end
