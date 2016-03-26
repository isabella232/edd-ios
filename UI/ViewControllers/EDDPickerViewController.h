//
//  EDDPickerViewController.h
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 24/12/2015.
//  Copyright © 2015 Easy Digital Downloads. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EDDPickerViewControllerDelegate <NSObject>

@required
- (void)didSelectRow:(NSString *)text tag:(int)tag;

@end

@interface EDDPickerViewController : UIViewController

@property (nonatomic, weak) id <EDDPickerViewControllerDelegate>delegate;
@property (nonatomic, strong) NSString *navBarTitle;
@property (nonatomic, strong) NSArray *rows;
@property (nonatomic) int tag;

@end