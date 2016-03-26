//
//  EDDPercentDrivenInteractiveTransition.h
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 08/01/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EDDPercentDrivenInteractiveTransition : UIPercentDrivenInteractiveTransition <UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning, UIViewControllerTransitioningDelegate>

@property (nonatomic, readwrite) id  <UIViewControllerContextTransitioning> transitionContext;

@end