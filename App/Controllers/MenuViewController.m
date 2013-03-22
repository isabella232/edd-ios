//
//  MenuViewController.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/9/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "MenuViewController.h"

#import "AboutViewController.h"
#import "CustomersViewController.h"
#import "EarningsViewController.h"
#import "MainViewController.h"
#import "MenuCell.h"
#import "NVSlideMenuController.h"
#import "ProductsViewController.h"
#import "SalesViewController.h"
#import "SetupViewController.h"
#import "UIColor+Helpers.h"

enum {
    MenuHomeRow = 0,
    MenuAboutRow,
	MenuEarningsRow,
	MenuProductsRow,
	MenuSalesRow,
    MenuSettingsRow,
    MenuRowCount
};

@interface MenuViewController ()

@end

@implementation MenuViewController

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
	
	[self setupNotifications];
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#eeeeee"];
    self.tableView.separatorColor = [UIColor blackColor];
	
    [self.tableView registerNib:[self menuCellNib] forCellReuseIdentifier:@"MenuCell"];
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)setupNotifications {	
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(setupDismissalRequested:) name:@"ShowRecentSales" object: nil];
}

- (void)setupDismissalRequested:(NSNotification *) notification {
	[self showSalesController];
}

- (UINib *)menuCellNib {
    return [UINib nibWithNibName:@"MenuCell" bundle:nil];
}

- (BOOL)shouldAutorotate {
	return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MenuRowCount;
}

- (void)configureCell:(MenuCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {            
        case MenuAboutRow:
            cell.label.text = @"About";
            break;
			
        case MenuEarningsRow:
            cell.label.text = @"Earnings";
            break;
			
        case MenuHomeRow:
            cell.label.text = @"Home";
            break;
            
        case MenuProductsRow:
            cell.label.text = @"Products";
            break;
            
        case MenuSalesRow:
            cell.label.text = @"Sales";
            break;
            
        case MenuSettingsRow:
            cell.label.text = @"Setup";
            break;
            
        default:
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MenuCell";
    MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

#pragma mark - table view delegate

- (BOOL)isShowingClass:(Class)class {
    UIViewController *controller = self.slideMenuController.contentViewController;
    if ([controller isKindOfClass:class]) {
        return YES;
    }
    
    if ([controller isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *)controller;
        if ([navController.visibleViewController isKindOfClass:class]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)showControllerClass:(Class)class {
    if ([self isShowingClass:class]) {
        [self.slideMenuController toggleMenuAnimated:self];
    } else {
        id mainVC = [[class alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:mainVC];
        [self.slideMenuController setContentViewController:nav
                                                  animated:YES
                                                completion:nil];
    }
}

- (void)showAboutController {
    [self showControllerClass:[AboutViewController class]];
}

- (void)showEarningsController {
    [self showControllerClass:[EarningsViewController class]];
}

- (void)showMainController {
    [self showControllerClass:[MainViewController class]];
}

- (void)showProductsController {
    [self showControllerClass:[ProductsViewController class]];
}

- (void)showSalesController {
    [self showControllerClass:[SalesViewController class]];
}

- (void)showSetupController {
    [self showControllerClass:[SetupViewController class]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case MenuAboutRow:
            [self showAboutController];
            break;
        case MenuEarningsRow:
            [self showEarningsController];
            break;
        case MenuHomeRow:
            [self showMainController];
            break;
        case MenuProductsRow:
            [self showProductsController];
            break;
        case MenuSalesRow:
            [self showSalesController];
            break;
        case MenuSettingsRow:
            [self showSetupController];
            break;
    }
}

@end
