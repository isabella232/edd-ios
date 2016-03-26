//
//  EDDHelpers.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 10/25/14.
//  Copyright (c) 2014 Easy Digital Downloads. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#define IS_IPHONE_5_5_INCH_SCREEN (([[UIScreen mainScreen] bounds].size.height-736)?NO:YES)

#define IS_IPHONE_4_7_INCH_SCREEN (([[UIScreen mainScreen] bounds].size.height-667)?NO:YES)

#define IS_IPHONE_4_INCH_SCREEN (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)

#define IS_IPHONE_3_5_INCH_SCREEN (([[UIScreen mainScreen] bounds].size.height-480)?NO:YES)

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

#define RADIANS_TO_DEGREES(angle) (angle*180.0 / M_PI)

@interface EDDHelpers : NSObject

+ (BOOL)isHandset;

+ (BOOL)isTablet;

+ (BOOL)isSimulator;

@end
