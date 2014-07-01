//
//  MenuViewController.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/9/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "MenuViewController.h"

#import "AboutViewController.h"
#import "CommissionsViewController.h"
#import "EarningsViewController.h"
#import "EDDAPIClient.h"
#import "EDDSlideMenuController.h"
#import "MainViewController.h"
#import "MenuCell.h"
#import "ProductsViewController.h"
#import "SalesViewController.h"
#import "SAMGradientView.h"
#import "SettingsHelper.h"
#import "SitesViewController.h"
#import "UIColor+Helpers.h"
#import "UIView+EDDAdditions.h"

enum {
    MenuHomeRow = 0,
	MenuEarningsRow,
	MenuProductsRow,
	MenuSalesRow,
    MenuAboutRow,
    MenuSettingsRow,
    MenuRowCount
};

#define kSectionHeaderHeight 26.0f

@interface MenuViewController ()

@end

@implementation MenuViewController

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#eeeeee"];
	
    [self.tableView registerNib:[self menuCellNib] forCellReuseIdentifier:@"MenuCell"];
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
	[self.tableView reloadData];
}

- (UINib *)menuCellNib {
    return [UINib nibWithNibName:@"MenuCell" bundle:nil];
}

- (BOOL)shouldAutorotate {
	return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self siteCount] > 1 ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		if ([SettingsHelper isCommissionOnlySite]) {
			return 3;
		} else if ([SettingsHelper isStandardAndCommissionSite]) {
			return MenuRowCount + 1;
		} else {
			return MenuRowCount;
		}
	}
	return [self siteCount];
}

- (void)configureCell:(MenuCell *)cell forIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		[self setupMenuCell:cell forIndexPath:indexPath];
	} else {
		NSDictionary *site = [self getSite:indexPath.row];
		
		cell.siteID = [site objectForKey:KEY_FOR_SITE_ID];
		cell.label.text = [site objectForKey:KEY_FOR_SITE_NAME];
	}
}

- (void)setupMenuCell:(MenuCell *)cell forIndexPath:(NSIndexPath *)indexPath {
	if ([SettingsHelper isCommissionOnlySite]) {
		switch (indexPath.row) {
			case 0:
				cell.label.text = @"Home";
				break;
			case 1:
				cell.label.text = @"Commissions";
				break;
			case 2:
				cell.label.text = @"Setup";
				break;
		}
	} else if ([SettingsHelper isStandardAndCommissionSite]) {
		switch (indexPath.row) {
			case 0:
				cell.label.text = @"Home";
				break;
			case 1:
				cell.label.text = @"Earnings";
				break;
			case 2:
				cell.label.text = @"Products";
				break;
			case 3:
				cell.label.text = @"Sales";
				break;
			case 4:
				cell.label.text = @"Commissions";
				break;
			case 5:
				cell.label.text = @"About";
				break;
			case 6:
				cell.label.text = @"Setup";
				break;
		}
	} else {
		switch (indexPath.row) {
			case 0:
				cell.label.text = @"Home";
				break;
			case 1:
				cell.label.text = @"Earnings";
				break;
			case 2:
				cell.label.text = @"Products";
				break;
			case 3:
				cell.label.text = @"Sales";
				break;
			case 4:
				cell.label.text = @"About";
				break;
			case 5:
				cell.label.text = @"Setup";
				break;
		}
	}
	
	cell.labelCheckmark.text = @"";
	cell.labelCheckmark.hidden = YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MenuCell";
    MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section	{
	switch (section) {
		case 0:
			return @"EASY DIGITAL DOWNLOADS";
		case 1:
			return NSLocalizedString(@"SITES", nil);
		default:
			return nil;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return ([self tableView:tableView titleForHeaderInSection:section]) ? kSectionHeaderHeight : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = [self tableView:tableView titleForHeaderInSection:section];
    if (title == nil) return nil;
	
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(10, 0, 300, kSectionHeaderHeight);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithHexString:@"#363b3f"];
    label.font = [UIFont boldSystemFontOfSize:13];
    label.text = title;
    
    SAMGradientView *gradient = [[SAMGradientView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kSectionHeaderHeight)];
    gradient.backgroundColor = [UIColor clearColor];
	
    UIColor *first = [UIColor colorWithHexString:@"#ffffff"];
    UIColor *second = [UIColor colorWithHexString:@"#cccccc"];
    gradient.gradientColors = [NSArray arrayWithObjects:
                       first,
                       second,
                       nil];
    gradient.gradientDirection = SAMGradientViewDirectionVertical;
    
    [gradient addSubview:label];
	
    return gradient;
}

- (int)siteCount {
	return [[[SettingsHelper getSites] allKeys] count];
}

- (NSDictionary *)getSite:(int)index {
	NSArray *keys = [[SettingsHelper getSites] allKeys];
	id aKey = [keys objectAtIndex:index];
	NSDictionary *site = [[SettingsHelper getSites] objectForKey:aKey];
	return site;
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath: indexPath animated: NO];
	
	if (indexPath.section == 0) {
		if ([SettingsHelper isCommissionOnlySite]) {
			switch (indexPath.row) {
				case 0:
					[self showMainController];
					break;
				case 1:
					[self showCommissionsController];
					break;
				case 2:
					[self showSetupController];
					break;
			}
		} else if ([SettingsHelper isStandardAndCommissionSite]) {
			switch (indexPath.row) {
				case 0:
					[self showMainController];
					break;
				case 1:
					[self showEarningsController];
					break;
				case 2:
					[self showProductsController];
					break;
				case 3:
					[self showSalesController];
					break;
				case 4:
					[self showCommissionsController];
					break;
				case 5:
					[self showAboutController];
					break;
				case 6:
					[self showSetupController];
					break;
			}
		} else {
			switch (indexPath.row) {
				case 0:
					[self showMainController];
					break;
				case 1:
					[self showEarningsController];
					break;
				case 2:
					[self showProductsController];
					break;
				case 3:
					[self showSalesController];
					break;
				case 4:
					[self showAboutController];
					break;
				case 5:
					[self showSetupController];
					break;
			}
		}
	} else {
		NSDictionary *site = [self getSite:indexPath.row];
		[SettingsHelper setCurrentSiteID:[site objectForKey:KEY_FOR_SITE_ID]];
		[[EDDAPIClient sharedClient] reload];
		[self.tableView reloadData];
		
		if ([self isShowingClass:[MainViewController class]]) {
			UINavigationController *navController = (UINavigationController *)self.slideMenuController.contentViewController;
			navController.navigationBar.translucent = NO;
			MainViewController *main = (MainViewController *)navController.visibleViewController;
			[main reload:nil];
			[self.slideMenuController toggleMenuAnimated:self];
		} else {
			id mainVC = [[MainViewController alloc] init];
			UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:mainVC];
			nav.navigationBar.translucent = NO;
			[self.slideMenuController closeMenuBehindContentViewController:nav
																  animated:YES
																completion:nil];
		}
	}
}

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
		nav.navigationBar.translucent = NO;
		[self.slideMenuController closeMenuBehindContentViewController:nav
															  animated:YES
															completion:nil];
    }
}

- (void)showAboutController {
    [self showControllerClass:[AboutViewController class]];
}

- (void)showCommissionsController {
	[self showControllerClass:[CommissionsViewController class]];
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
    [self showControllerClass:[SitesViewController class]];
}

@end
