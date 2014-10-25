//
//  EDDMenuViewController.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/9/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "EDDMenuViewController.h"

#import "EDDAboutViewController.h"
#import "EDDAPIClient.h"
#import "EDDCommissionsViewController.h"
#import "EDDCustomersListViewController.h"
#import "EDDEarningsViewController.h"
#import "EDDHelpers.h"
#import "EDDMainViewController.h"
#import "EDDProductsViewController.h"
#import "EDDSalesViewController.h"
#import "EDDSettingsHelper.h"
#import "EDDSlideMenuController.h"
#import "EDDStoreCommissionsListViewController.h"
#import "EDDSitesViewController.h"
#import "MenuCell.h"
#import "SAMGradientView.h"
#import "UIColor+Helpers.h"
#import "UIView+EDDAdditions.h"

enum {
    MenuHomeRow = 0,
	MenuEarningsRow,
    MenuProductsRow,
    MenuSalesRow,
    MenuCustomersRow,
    MenuAboutRow,
    MenuSettingsRow,
    MenuRowCount
};

@interface EDDMenuViewController ()

@end

@implementation EDDMenuViewController

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
    
    self.tableView.scrollEnabled = [EDDHelpers isHandset];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
	[self.tableView reloadData];
}

- (void)refreshMenu {
    if ([EDDHelpers isHandset]) return;
    
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
		if ([EDDSettingsHelper isCommissionOnlySite]) {
			return 3;
		} else if ([EDDSettingsHelper isStandardAndCommissionSite] || [EDDSettingsHelper isStandardAndStoreCommissionSite]) {
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
	if ([EDDSettingsHelper isCommissionOnlySite]) {
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
	} else if ([EDDSettingsHelper isStandardAndCommissionSite] || [EDDSettingsHelper isStandardAndStoreCommissionSite]) {
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
                cell.label.text = @"Customers";
                break;
			case 5:
				cell.label.text = @"Commissions";
				break;
			case 6:
				cell.label.text = @"About";
				break;
			case 7:
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
                cell.label.text = @"Customers";
                break;
			case 5:
				cell.label.text = @"About";
				break;
			case 6:
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
    CGFloat headerHeight = [self headerHeightForSection:section];
    
    return ([self tableView:tableView titleForHeaderInSection:section]) ? headerHeight : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = [self tableView:tableView titleForHeaderInSection:section];
    if (title == nil) return nil;
	
    return [EDDHelpers isHandset] || section != 0 ? [self headerViewForHandset:section] : [self headerViewForTablet:section];
}

- (UIView *)headerViewForHandset:(NSInteger)section  {
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(10, 0, 300, 26.0f);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithHexString:@"#363b3f"];
    label.font = [UIFont boldSystemFontOfSize:13];
    label.text = [self tableView:self.tableView titleForHeaderInSection:section];
    
    SAMGradientView *gradient = [[SAMGradientView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 26.0f)];
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

- (UIView *)headerViewForTablet:(NSInteger)section  {
    SAMGradientView *gradient = [[SAMGradientView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20.0f)];
    
    gradient.backgroundColor = [UIColor colorWithHexString:@"#1c5585"];
    
    return gradient;
}

- (CGFloat)headerHeightForSection:(NSInteger)section {
    CGFloat height = 26.0f;
    
    if ([EDDHelpers isTablet] && section == 0) {
        height = 64.5f;
    }
    
    return height;
}

- (NSInteger)siteCount {
	return [[[EDDSettingsHelper getSites] allKeys] count];
}

- (NSDictionary *)getSite:(NSInteger)index {
	NSArray *keys = [[EDDSettingsHelper getSites] allKeys];
	id aKey = [keys objectAtIndex:index];
	NSDictionary *site = [[EDDSettingsHelper getSites] objectForKey:aKey];
	return site;
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath: indexPath animated: NO];
	
	if (indexPath.section == 0) {
		if ([EDDSettingsHelper isCommissionOnlySite]) {
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
		} else if ([EDDSettingsHelper isStandardAndCommissionSite] || [EDDSettingsHelper isStandardAndStoreCommissionSite]) {
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
                    [self showCustomersController];
                    break;
				case 5:
					[self showCommissionsController];
					break;
				case 6:
					[self showAboutController];
                    break;
                case 7:
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
                    [self showCustomersController];
                    break;
				case 5:
					[self showAboutController];
					break;
				case 6:
					[self showSetupController];
					break;
			}
		}
	} else {
		NSDictionary *site = [self getSite:indexPath.row];
		[EDDSettingsHelper setCurrentSiteID:[site objectForKey:KEY_FOR_SITE_ID]];
		[[EDDAPIClient sharedClient] reload];
		[self.tableView reloadData];
		
		if ([self isShowingClass:[EDDMainViewController class]]) {
			UINavigationController *navController = (UINavigationController *)self.slideMenuController.contentViewController;
			navController.navigationBar.translucent = NO;
			EDDMainViewController *main = (EDDMainViewController *)navController.visibleViewController;
			[main reload:nil];
			[self.slideMenuController toggleMenuAnimated:self];
		} else {
			id mainVC = [[EDDMainViewController alloc] init];
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
    [self showControllerClass:[EDDAboutViewController class]];
}

- (void)showCommissionsController {
    if ([EDDSettingsHelper isStandardAndStoreCommissionSite]) {
        [self showControllerClass:[EDDStoreCommissionsListViewController class]];
    } else {
        [self showControllerClass:[EDDCommissionsViewController class]];
    }
}

- (void)showEarningsController {
    [self showControllerClass:[EDDEarningsViewController class]];
}

- (void)showMainController {
    [self showControllerClass:[EDDMainViewController class]];
}

- (void)showProductsController {
    [self showControllerClass:[EDDProductsViewController class]];
}

- (void)showSalesController {
    [self showControllerClass:[EDDSalesViewController class]];
}

- (void)showCustomersController {
    [self showControllerClass:[EDDCustomersListViewController class]];
}

- (void)showSetupController {
    [self showControllerClass:[EDDSitesViewController class]];
}

@end
