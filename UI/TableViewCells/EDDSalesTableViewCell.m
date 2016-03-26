//
//  EDDSalesTableViewCell.m
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 03/01/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

#import "EDDSalesTableViewCell.h"

#import "UIColor+EDDUIColorCategory.h"

@interface EDDSalesTableViewCell ()

@property (nonatomic, strong) UILabel *emailLabel;

@end

@implementation EDDSalesTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.backgroundColor = [UIColor EDDSecondaryGreyColor];
        
        UILabel *emailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        emailLabel.backgroundColor = [UIColor clearColor];
        emailLabel.opaque = YES;
        emailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        emailLabel.textAlignment = NSTextAlignmentLeft;
        emailLabel.textColor = [UIColor blackColor];
        emailLabel.text = @"Email";
        
        self.emailLabel = emailLabel;
        
        [self addSubview:self.emailLabel];
    }
    
    return self;
}

- (void)updateConstraints
{
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.emailLabel
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.contentView
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1.0
                                                                    constant:5.0f]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.emailLabel
                                                                   attribute:NSLayoutAttributeLeft
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.contentView
                                                                   attribute:NSLayoutAttributeLeft
                                                                  multiplier:1.0
                                                                    constant:10.0f]];
    
    [super updateConstraints];
}

@end
