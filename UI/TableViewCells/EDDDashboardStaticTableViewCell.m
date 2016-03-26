//
//  EDDDashboardStaticTableViewCell.m
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 26/12/2015.
//  Copyright © 2015 Easy Digital Downloads. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "BEMSimpleLineGraphView.h"

#import "EDDDashboardStaticTableViewCell.h"
#import "EDDUILabel.h"

#import "UIColor+EDDUIColorCategory.h"

@interface EDDDashboardStaticTableViewCell () <BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate>

@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *statLabel;
@property (nonatomic, strong) UILabel *currentMonthStat;
@property (nonatomic, strong) UILabel *lastMonthStat;
@property (nonatomic, strong) UILabel *totalStat;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) BEMSimpleLineGraphView *graph;
@property (nonatomic, strong) NSMutableArray *dates;
@property (nonatomic, strong) NSMutableArray *graphData;

@end

@implementation EDDDashboardStaticTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        self.layer.opaque = YES;
        self.opaque = YES;
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        [self draw];
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.isCommissions = NO;
    self.isEarnings = NO;
    self.isSales = NO;
    self.currencyFormatted = NO;
    
    self.statLabel.text = @"";
    self.currentMonthStat.text = @"";
    self.lastMonthStat.text = @"";
    self.totalStat.text = @"";
    
    [self.graph removeFromSuperview];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView setNeedsDisplay];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
}

- (void)draw
{
    CGFloat height = 120;
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, [[UIScreen mainScreen] bounds].size.width - 20, height)];
    self.containerView.layer.masksToBounds = NO;
    self.containerView.layer.cornerRadius = 4.0f;
    self.containerView.layer.shadowOffset = CGSizeMake(0, 0);
    self.containerView.layer.shadowRadius = 2;
    self.containerView.layer.shadowOpacity = 0.4;
    self.containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.containerView.backgroundColor = [UIColor EDDColorWithRed:34 green:68 blue:97];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.opaque = YES;
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightLight];
    [self.containerView addSubview:self.titleLabel];
    
    self.statLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.statLabel.backgroundColor = [UIColor clearColor];
    self.statLabel.opaque = YES;
    self.statLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.statLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.statLabel.textAlignment = NSTextAlignmentRight;
    self.statLabel.textColor = [UIColor whiteColor];
    self.statLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightLight];
    [self.containerView addSubview:self.statLabel];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.activityIndicator.center = CGPointMake(CGRectGetWidth(self.containerView.bounds) - 20, 20);
    [self.activityIndicator startAnimating];
    [self.containerView addSubview:self.activityIndicator];
    
    [self addSubview:self.containerView];
}

- (void)spin
{
    [self.activityIndicator startAnimating];
}

- (void)resizeForSmallCell
{
    self.containerView.frame = CGRectMake(10, 10, [[UIScreen mainScreen] bounds].size.width - 20, 40);
}

- (void)resizeForNormalCell
{
    self.containerView.frame = CGRectMake(10, 10, [[UIScreen mainScreen] bounds].size.width - 20, 120);
}

- (void)resizeForLargeCell
{
    self.containerView.frame = CGRectMake(10, 10, [[UIScreen mainScreen] bounds].size.width - 20, 240);
}

- (void)drawAdditionalSubviews
{
    NSString *currentMonthStatLabel;
    NSString *lastMonthStatLabel;
    NSString *totalStatLabel;
    
    if (self.isCommissions) {
        currentMonthStatLabel = @"Unpaid:";
        lastMonthStatLabel = @"Paid:";
        totalStatLabel = @"Revoked";
    } else {
        currentMonthStatLabel = @"Current Month:";
        lastMonthStatLabel = @"Last Month:";
        totalStatLabel = @"Total";
    }
    
    self.currentMonthStat = [[UILabel alloc] initWithFrame:CGRectZero];
    self.lastMonthStat = [[UILabel alloc] initWithFrame:CGRectZero];
    self.totalStat = [[UILabel alloc] initWithFrame:CGRectZero];
    
    self.currentMonthStat.backgroundColor = [UIColor clearColor];
    self.currentMonthStat.opaque = YES;
    self.currentMonthStat.lineBreakMode = NSLineBreakByTruncatingTail;
    self.currentMonthStat.translatesAutoresizingMaskIntoConstraints = NO;
    self.currentMonthStat.textAlignment = NSTextAlignmentLeft;
    self.currentMonthStat.textColor = [UIColor whiteColor];
    self.currentMonthStat.text = currentMonthStatLabel;
    self.currentMonthStat.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    
    self.lastMonthStat.backgroundColor = [UIColor clearColor];
    self.lastMonthStat.opaque = YES;
    self.lastMonthStat.lineBreakMode = NSLineBreakByTruncatingTail;
    self.lastMonthStat.translatesAutoresizingMaskIntoConstraints = NO;
    self.lastMonthStat.textAlignment = NSTextAlignmentLeft;
    self.lastMonthStat.textColor = [UIColor whiteColor];
    self.lastMonthStat.text = lastMonthStatLabel;
    self.lastMonthStat.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    
    self.totalStat.backgroundColor = [UIColor clearColor];
    self.totalStat.opaque = YES;
    self.totalStat.lineBreakMode = NSLineBreakByTruncatingTail;
    self.totalStat.translatesAutoresizingMaskIntoConstraints = NO;
    self.totalStat.textAlignment = NSTextAlignmentLeft;
    self.totalStat.textColor = [UIColor whiteColor];
    self.totalStat.text = totalStatLabel;
    self.totalStat.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    
    if (!self.isStoreCommissions) {
        [self.containerView addSubview:self.currentMonthStat];
        [self.containerView addSubview:self.lastMonthStat];
        [self.containerView addSubview:self.totalStat];
    }
}

- (void)updateConstraints
{
    if (!self.didSetupConstraints) {
        self.didSetupConstraints = YES;
        
        [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        
        CGFloat topConstant;
        
        if (self.isStoreCommissions) {
            topConstant = 8.0f;
        } else {
            topConstant = 5.0f;
        }
        
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                       attribute:NSLayoutAttributeTop
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.containerView
                                                                       attribute:NSLayoutAttributeTop
                                                                      multiplier:1.0
                                                                        constant:topConstant]];
        
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.statLabel
                                                                       attribute:NSLayoutAttributeTop
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.containerView
                                                                       attribute:NSLayoutAttributeTop
                                                                      multiplier:1.0
                                                                        constant:topConstant]];
        
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                       attribute:NSLayoutAttributeLeft
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.containerView
                                                                       attribute:NSLayoutAttributeLeft
                                                                      multiplier:1.0
                                                                        constant:10.0f]];
        
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.statLabel
                                                                       attribute:NSLayoutAttributeRight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.containerView
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1.0
                                                                        constant:-10.0f]];
        
        if (self.isSales || self.isEarnings || self.isCommissions) {
            [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_currentMonthStat]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_currentMonthStat)]];
            [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_lastMonthStat]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_lastMonthStat)]];
            [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_totalStat]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_totalStat)]];
            [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[_currentMonthStat]-[_lastMonthStat]-[_totalStat]" options:NSLayoutFormatAlignAllTrailing metrics:nil views:NSDictionaryOfVariableBindings(_currentMonthStat, _lastMonthStat, _totalStat)]];
        }
    }
    
    [super updateConstraints];
}

- (void)configureTitle
{
    self.titleLabel.text = self.title;
}

- (void)configureWithProperties
{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    f.minimumFractionDigits = 2;
    f.maximumFractionDigits = 2;
    f.roundingMode = NSNumberFormatterRoundUp;
    
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:self.site.currency];
    NSString *currencySymbol = [NSString stringWithFormat:@"%@",[locale displayNameForKey:NSLocaleCurrencySymbol value:self.site.currency]];

    if (self.currencyFormatted && !self.isSales) {
        NSNumber *number = [f numberFromString:self.stat];
        self.statLabel.text = [NSString stringWithFormat:@"%@%@", currencySymbol, [f stringFromNumber:number]];
    } else {
        self.statLabel.text = self.stat;
    }
    
    if (self.data[@"stats"] && (self.isSales || self.isEarnings)) {
        [self.activityIndicator stopAnimating];
    }
    
    if (self.data[@"commissions"] && self.isCommissions) {
        [self.activityIndicator stopAnimating];
    }
    
    if (self.isSales && self.data[@"stats"] && self.data[@"sales_graph"]) {
        self.currentMonthStat.text = [NSString stringWithFormat:@"Current Month: %@", self.data[@"stats"][@"stats"][@"sales"][@"current_month"]];
        self.lastMonthStat.text = [NSString stringWithFormat:@"Last Month: %@", self.data[@"stats"][@"stats"][@"sales"][@"last_month"]];
        self.totalStat.text = [NSString stringWithFormat:@"Total: %@", self.data[@"stats"][@"stats"][@"sales"][@"totals"]];
        
        [self drawGraph:@"sales"];
    }
    
    if (self.isEarnings && self.data[@"stats"] && self.data[@"earnings_graph"]) {
        NSNumber *currentMonth = self.data[@"stats"][@"stats"][@"earnings"][@"current_month"];
        NSNumber *lastMonth = self.data[@"stats"][@"stats"][@"earnings"][@"last_month"];
        NSNumber *total = self.data[@"stats"][@"stats"][@"earnings"][@"totals"];
        
        self.currentMonthStat.text = [NSString stringWithFormat:@"Current Month: %@%@", currencySymbol, [f stringFromNumber:currentMonth]];
        self.lastMonthStat.text = [NSString stringWithFormat:@"Last Month: %@%@", currencySymbol, [f stringFromNumber:lastMonth]];
        self.totalStat.text = [NSString stringWithFormat:@"Total: %@%@", currencySymbol, [f stringFromNumber:total]];
        
        [self drawGraph:@"earnings"];
    }
    
    if (self.isCommissions) {
        NSNumber *currentMonth = [f numberFromString:self.data[@"commissions"][@"totals"][@"unpaid"]];
        NSNumber *lastMonth = [f numberFromString:self.data[@"commissions"][@"totals"][@"paid"]];
        NSNumber *total = [f numberFromString:self.data[@"commissions"][@"totals"][@"revoked"]];
        
        self.currentMonthStat.text = currentMonth ? [NSString stringWithFormat:@"Unpaid: %@%@", currencySymbol, [f stringFromNumber:currentMonth]] : NSLocalizedString(@"Unpaid:", @"");
        self.lastMonthStat.text = lastMonth ? [NSString stringWithFormat:@"Paid: %@%@", currencySymbol, [f stringFromNumber:lastMonth]] : NSLocalizedString(@"Paid:", @"");
        self.totalStat.text = total ? [NSString stringWithFormat:@"Revoked: %@%@", currencySymbol, [f stringFromNumber:total]] : NSLocalizedString(@"Revoked:", @"");
    }
    
    [self.currentMonthStat sizeToFit];
    [self.lastMonthStat sizeToFit];
    [self.totalStat sizeToFit];
    
    self.didSetupConstraints = NO;
    [self updateConstraints];
    
//    [self setNeedsDisplay];
//    [self setNeedsLayout];
}

- (void)drawGraph:(NSString *)endpoint
{
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();

    UIColor* gradBegin = [UIColor colorWithWhite:1 alpha:0];
    UIColor* gradEnd = [UIColor colorWithWhite:1 alpha:0.15];
    NSArray* gradColours = [NSArray arrayWithObjects:
                            (id)gradBegin.CGColor,
                            (id)gradBegin.CGColor,
                            (id)gradEnd.CGColor,
                            (id)gradEnd.CGColor, nil];
    CGFloat gradLocs[] = { 1, 0.9, 0.5, 0 };
    CGGradientRef gradient = CGGradientCreateWithColors(colourSpace, (__bridge CFArrayRef)gradColours, gradLocs);
    
    self.graphData = [NSMutableArray array];
    self.dates = [NSMutableArray array];
    
    NSString *subkey = [NSString stringWithFormat:@"%@_graph", endpoint];
    
    NSArray *sortedKeys = [[self.data[subkey][endpoint] allKeys] sortedArrayUsingSelector: @selector(compare:)];
    
    for (NSString *key in sortedKeys) {
        NSDictionary *subDictionary = [self.data[subkey][endpoint] objectForKey:key];
        [self.graphData addObject:subDictionary];
        
        NSString *date = [key substringFromIndex:6];
        
        NSRange range = NSMakeRange(4, 2);
        int month = [[key substringWithRange:range] intValue];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        NSString *monthName = [[df monthSymbols] objectAtIndex:(month-1)];
        [self.dates addObject:[NSString stringWithFormat:@"%@ %@", date, [monthName substringWithRange:NSMakeRange(0, 3)]]];
    }
    
    self.graph = [[BEMSimpleLineGraphView alloc] init];
    
    self.graph.dataSource = self;
    self.graph.delegate = self;
    
    self.graph.frame = CGRectMake(10, 120, self.containerView.frame.size.width - 20, 115);
    
    self.graph.gradientBottom = gradient;
    self.graph.enableYAxisLabel = YES;
    self.graph.autoScaleYAxis = YES;
    self.graph.enableReferenceXAxisLines = NO;
    self.graph.enableReferenceYAxisLines = YES;
    self.graph.enableReferenceAxisFrame = NO;
    self.graph.animationGraphStyle = BEMLineAnimationNone;
    self.graph.colorBackgroundXaxis = [UIColor clearColor];
    self.graph.colorBackgroundYaxis = [UIColor clearColor];
    self.graph.colorTop = [UIColor clearColor];
    self.graph.colorBottom = [UIColor clearColor];
    self.graph.backgroundColor = [UIColor clearColor];
    self.graph.tintColor = [UIColor clearColor];
    self.graph.colorYaxisLabel = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5f];
    self.graph.colorXaxisLabel = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5f];
    self.graph.alwaysDisplayDots = YES;
    self.graph.enablePopUpReport = YES;
    self.graph.enableTouchReport = YES;

    [self.containerView addSubview:self.graph];
}

#pragma mark - BEMSimpleLineGraphDataSource

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph
{
    return (int) [self.graphData count];
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index
{
    return [[self.graphData objectAtIndex:index] doubleValue];
}

#pragma mark - BEMSimpleLineGraphDelegate

- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return 2;
}

- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index
{
    return [self.dates objectAtIndex:index];
}

@end