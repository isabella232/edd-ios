//
//  UIColor+EDDUIColorCategory.h
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 26/08/2015.
//  Copyright © 2015 Easy Digital Downloads. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (EDDUIColorCategory)

+ (UIColor *)EDDBlueColor;
+ (UIColor *)EDDGreyColor;
+ (UIColor *)EDDSecondaryGreyColor;

+ (UIColor *)colorWithHex:(long)hexColor;
+ (UIColor *)colorWithRGB:(NSArray *)arrayColor;
+ (UIColor *)colorWithRGB:(NSArray *)arrayColor alpha:(CGFloat)alpha;

+ (UIColor *)EDDColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;
+ (UIColor *)EDDColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;

@end
