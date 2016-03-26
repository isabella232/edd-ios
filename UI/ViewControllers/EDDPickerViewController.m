//
//  EDDPickerViewController.m
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 24/12/2015.
//  Copyright © 2015 Easy Digital Downloads. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "EDDPickerViewController.h"
#import "EDDLaunchCell.h"

#import "UIColor+EDDUIColorCategory.h"

@interface EDDPickerViewController () <UINavigationBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation EDDPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurEffectView setFrame:self.view.bounds];
    
    [self.view addSubview:blurEffectView];
    
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    navigationBar.delegate = self;
    navigationBar.translucent = YES;
    navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:_navBarTitle];
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed:)];
    navigationItem.leftBarButtonItem = cancelBarButtonItem;
    navigationBar.items = [NSArray arrayWithObjects:navigationItem, nil];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navigationBar.frame.size.height,self.view.frame.size.width, self.view.frame.size.height - navigationBar.frame.size.height)];
    tableView.scrollEnabled = YES;
    tableView.showsVerticalScrollIndicator = YES;
    tableView.userInteractionEnabled = YES;
    tableView.bounces = YES;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:0.3f];
    tableView.tableFooterView = [UIView new];
    self.tableView = tableView;
    [self.tableView registerClass:[EDDLaunchCell class] forCellReuseIdentifier:@"pickerCell"];
    
    [self.view addSubview:navigationBar];
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancelButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _rows.count;
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"pickerCell";
    EDDLaunchCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[EDDLaunchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = [_rows objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = [_rows objectAtIndex:indexPath.row];
    [self.delegate didSelectRow:text tag:self.tag];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
