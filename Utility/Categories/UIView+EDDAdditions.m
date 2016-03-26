//
//  UIView+EDDAdditions.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 7/1/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import "UIView+EDDAdditions.h"

@implementation UIView (EDDAdditions)

+ (id)view {
    NSString *nibName = [self nibName];
    UIView *view = nil;
    
    if([[NSBundle mainBundle] pathForResource:nibName ofType:@"nib"] != nil) {
        NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
        view = [nibViews objectAtIndex:0];
    }
    
    return view;
}

+ (NSString*)nibName {
    Class class = [self class];
    return [self deviceSpecificNibWithName:NSStringFromClass(class)];
}

+ (NSString*)deviceSpecificNibWithName:(NSString *)baseNibName {
    NSString *result = baseNibName;
    
    NSString *deviceSpecificSuffix = @"";
    NSString *deviceSpecificNibName = @"";
    
    if (![result hasSuffix:deviceSpecificSuffix]) {
        deviceSpecificNibName = [result stringByAppendingString:deviceSpecificSuffix];
        
        if ([[NSBundle mainBundle] pathForResource:deviceSpecificNibName ofType:@"nib"] != nil) {
            result = deviceSpecificNibName;
        }
    }
    
    return result;
}

- (void)disableScrollsToTopPropertyOnMeAndAllSubviews {
    if ([self isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)self;
        scrollView.scrollsToTop = NO;
    }
	
    for (UIView *subview in self.subviews) {
        [subview disableScrollsToTopPropertyOnMeAndAllSubviews];
    }
}

// From https://github.com/damienromito/UIView-UpdateAutoLayoutConstraints

- (BOOL)setConstraintConstant:(CGFloat)constant forAttribute:(NSLayoutAttribute)attribute {
    NSLayoutConstraint *constraint = [self constraintForAttribute:attribute];
	
    if (constraint) {
        [constraint setConstant:constant];
        return YES;
    } else {
        UIView*container = (attribute == NSLayoutAttributeWidth || attribute == NSLayoutAttributeHeight) ? self : self.superview;
        [container addConstraint: [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:constant]];
        return NO;
    }
}

- (CGFloat)constraintConstantforAttribute:(NSLayoutAttribute)attribute {
    NSLayoutConstraint *constraint = [self constraintForAttribute:attribute];
    
    if (constraint) {
        return constraint.constant;
    } else {
        return NAN;
    }
	
}

- (NSLayoutConstraint *)constraintForAttribute:(NSLayoutAttribute)attribute {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstAttribute = %d && firstItem = %@", attribute, self];
    UIView*container = (attribute == NSLayoutAttributeWidth || attribute == NSLayoutAttributeHeight) ? self : self.superview;
    NSArray *fillteredArray = [[container constraints] filteredArrayUsingPredicate:predicate];
    if (fillteredArray.count == 0) {
        return nil;
    } else {
        return fillteredArray.firstObject;
    }
}

- (void)hideByHeight:(BOOL)hidden {
    [self hideView:hidden byAttribute:NSLayoutAttributeHeight];
}

- (void)hideByWidth:(BOOL)hidden {
    [self hideView:hidden byAttribute:NSLayoutAttributeWidth];
}

- (void)hideView:(BOOL)hidden byAttribute:(NSLayoutAttribute)attribute {
    if (self.hidden != hidden) {
        CGFloat constraintConstant = [self constraintConstantforAttribute:attribute];
        
        if (hidden) {
            if (!isnan(constraintConstant)) {
                self.alpha = constraintConstant;
            } else {
                CGSize size = [self size];
                self.alpha = (attribute == NSLayoutAttributeHeight)?size.height:size.width;
            }
            
            [self setConstraintConstant:0 forAttribute:attribute];
            self.hidden = YES;
        } else {
            if (!isnan(constraintConstant) ) {
                self.hidden = NO;
                [self setConstraintConstant:self.alpha forAttribute:attribute];
                self.alpha = 1;
            }
        }
    }
}

- (CGSize)size {
    [self setNeedsLayout];
    return CGSizeMake(self.bounds.size.width, self.bounds.size.height);
}

- (UIView *) findFirstResponder {
    if (self.isFirstResponder) {
        return self;
    }
    
    for (UIView *subView in self.subviews) {
        UIView *firstResponder = [subView findFirstResponder];
        
        if (firstResponder != nil) {
            return firstResponder;
        }
    }
    
    return nil;
}

@end
