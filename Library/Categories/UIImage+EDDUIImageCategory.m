//
//  UIImage+EDDUIImageCategory.m
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 24/12/2015.
//  Copyright © 2015 Easy Digital Downloads. All rights reserved.
//

#import "UIImage+EDDUIImageCategory.h"

@implementation UIImage (EDDUIImageCategory)

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end