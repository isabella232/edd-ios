//
//  EDDSitesViewController.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 5/28/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "EDDSitesViewController.h"

#import "AppDelegate.h"
#import "EDDSettingsHelper.h"
#import "EDDSetupViewController.h"
#import "UIColor+Helpers.h"
#import "UIView+EDDAdditions.h"

@implementation EDDSitesViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
    self.title = NSLocalizedString(@"Site Setup", nil);
    
    [self setupNavButtons];
	
	[self.tableView setBackgroundView:nil];
    
	[self.tableView setBackgroundColor:[UIColor colorWithHexString:@"#ededed"]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [appDelegate.menuViewController refreshMenu];
	
	[self.tableView reloadData];
}

- (void)setupNavButtons {
    self.editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(toggleEdit)];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newSite)];
    
    self.navigationItem.rightBarButtonItems = @[ saveButton, self.editButton ];
}

- (void)toggleEdit {
    BOOL isEditing = self.tableView.isEditing;
    
    NSString *title = isEditing ? @"Done" : @"Edit";
    
    self.editButton.title = title;
    
    [self.tableView setEditing:!self.tableView.isEditing animated:YES];
}

- (void)newSite {
	[self selectSite:nil];
}

- (void)selectSite:(NSDictionary *)site {
	EDDSetupViewController *setupViewController = [[EDDSetupViewController alloc] initForSiteCreation:site];
    
    [self.navigationController pushViewController:setupViewController animated:YES];	
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self siteCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
	
	NSDictionary *site = [self getSite:indexPath.row];
	
	cell.textLabel.text = [site objectForKey:KEY_FOR_SITE_NAME];
	
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	
    return cell;
}

- (int)siteCount {
	return [[[EDDSettingsHelper getSites] allKeys] count];
}

- (NSDictionary *)getSite:(NSInteger)index {
	NSArray *keys = [[EDDSettingsHelper getSites] allKeys];
	id aKey = [keys objectAtIndex:index];
	NSDictionary *site = [[EDDSettingsHelper getSites] objectForKey:aKey];
	return site;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSDictionary *site = [self getSite:indexPath.row];
    
	[self selectSite:site];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		if ([self siteCount] > 1) {
			
			NSDictionary *site = [self getSite:indexPath.row];
			[EDDSettingsHelper removeSite:site];
			
			if ([[EDDSettingsHelper getCurrentSiteID] isEqualToString:[site objectForKey:KEY_FOR_SITE_ID]]) {
				NSDictionary *newCurrentSite = [self getSite:0];
				[EDDSettingsHelper setCurrentSiteID:[newCurrentSite objectForKey:KEY_FOR_SITE_ID]];
			}
			
			// delete site and reload table data
			[self.tableView reloadData];
            
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            
            [appDelegate.menuViewController refreshMenu];
			
		} else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You must have at least one site" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alert show];
		}
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	return [[UIView alloc] init];
}

@end
