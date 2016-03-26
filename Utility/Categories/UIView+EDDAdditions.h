//
//  UIView+EDDAdditions.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 7/1/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (EDDAdditions)

+ (id)view;

- (void)disableScrollsToTopPropertyOnMeAndAllSubviews;

- (void)hideByHeight:(BOOL)hidden;

- (void)hideByWidth:(BOOL)hidden;

- (UIView *)findFirstResponder;

@end
