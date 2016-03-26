//
//  UIColor+EDDUIColorCategory.m
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 26/08/2015.
//  Copyright © 2015 Easy Digital Downloads. All rights reserved.
//

#import "UIColor+EDDUIColorCategory.h"

@implementation UIColor (EDDUIColorCategory)

+ (UIColor *)EDDBlueColor
{
    return [[self class] EDDColorWithRed:32.0f green:86.0f blue:132.0f];
}

+ (UIColor *)EDDGreyColor
{
    return [[self class] EDDColorWithRed:238.0f green:238.0f blue:238.0f];
}

+ (UIColor *)EDDSecondaryGreyColor
{
    return [[self class] EDDColorWithRed:250.0f green:250.0f blue:250.0f];
}

#pragma mark - Colour Methods

+ (UIColor *)colorWithHex:(long)hexColor {
    CGFloat red = ((CGFloat)((hexColor & 0xFF0000) >> 16))/255.0f;
    CGFloat green = ((CGFloat)((hexColor & 0xFF00) >> 8))/255.0f;
    CGFloat blue = ((CGFloat)(hexColor & 0xFF))/255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}

+ (UIColor *)colorWithRGB:(NSArray *)arrayColor {
    CGFloat redColor = [arrayColor[0] floatValue];
    CGFloat greeenColor = [arrayColor[1] floatValue];
    CGFloat blueColor = [arrayColor[2] floatValue];
    return [[self class] colorWithRed:redColor green:greeenColor blue:blueColor alpha:1.0f];
}

+ (UIColor *)colorWithRGB:(NSArray *)arrayColor alpha:(CGFloat)alpha {
    return [[self class] colorWithRGB:arrayColor alpha:alpha];
}

+ (UIColor *)EDDColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
    return [[self class] EDDColorWithRed:red green:green blue:blue alpha:1.0f];
}

+ (UIColor *)EDDColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
}

@end
