//
//  EDDSaleDetailViewController.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/16/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "EDDSaleDetailViewController.h"

#import "EDDSalesSearchViewController.h"
#import "NSString+DateHelper.h"
#import "EDDSaleProduct.h"
#import "EDDSaleFee.h"
#import "SaleDetailCell.h"
#import "EDDSettingsHelper.h"
#import "UIColor+Helpers.h"
#import "UIView+EDDAdditions.h"

@interface EDDSaleDetailViewController () {
	EDDSale *_sale;
}

@end

@implementation EDDSaleDetailViewController

- (id)initWithSale:(EDDSale *)sale {
    self = [super init];
    if (self) {
		_sale = sale;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
    self.navigationItem.leftBarButtonItem = nil;
	
	[self.tableView setBackgroundView:nil];
	[self.tableView setBackgroundColor:[UIColor colorWithHexString:@"#ededed"]];
	
	self.title = [NSString stringWithFormat:@"Sale #%i", _sale.saleID];

	[self.tableView registerNib:[self saleCellNib] forCellReuseIdentifier:@"SaleDetailCell"];
}

- (UINib *)saleCellNib {
    return [UINib nibWithNibName:@"SaleDetailCell" bundle:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self hasFees] ? 4 : 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	int rows = 0;
	
	switch (section) {
		case 0:
			rows = 3 + [_sale.products count];
            
            if (_sale.discounts.count > 0) {
                rows++;
            }
            
			break;
		case 1:
			rows = [self hasFees] ? [_sale.fees count] : 3;
			break;
		case 2:
			rows = [self hasFees] ? 3 : 1;
			break;
        case 3:
            rows = 1;
            break;
	}
	
	return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
	cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#009100"];
	
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[formatter setCurrencyCode:[EDDSettingsHelper getCurrency]];
    
    // Configure the cell...
	
	if (indexPath.section == 0) {
		int date = [_sale.products count];
		int buyer = [_sale.products count] + 1;
        int gateway = [_sale.products count] + 2;
		int discount = [_sale.products count] + 3;
		
		// Details
		if (indexPath.row == date) {
			NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
			[timeFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
			NSString *timeString = [timeFormatter stringFromDate:_sale.date];
			
			cell.textLabel.text = @"Date:";
			cell.detailTextLabel.text = timeString;
			cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#000000"];
			
		} else if (indexPath.row == gateway) {
			cell.textLabel.text = @"Gateway:";
			cell.detailTextLabel.text = _sale.gateway;
			cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#000000"];
		} else if (indexPath.row == buyer) {
			cell.textLabel.text = @"Buyer:";
			cell.detailTextLabel.text = _sale.email;
			cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#000000"];
		} else if (indexPath.row == discount) {
			cell.textLabel.text = @"Discounts:";
			cell.detailTextLabel.text = _sale.discountFormat;
			cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#000000"];
		} else {
			EDDSaleProduct *product = [_sale.products objectAtIndex:indexPath.row];
			
			SaleDetailCell *saleDetailCell = [self.tableView dequeueReusableCellWithIdentifier:@"SaleDetailCell"];
			saleDetailCell.name.numberOfLines = 1;
			saleDetailCell.name.adjustsFontSizeToFitWidth = YES;
			saleDetailCell.name.text = product.displayName;
			saleDetailCell.price.text = [formatter stringFromNumber: [NSNumber numberWithFloat:product.price]];
			cell = saleDetailCell;
		}
		
	} else if (indexPath.section == 1 && [self hasFees]) {
		EDDSaleFee *fee = [_sale.fees objectAtIndex:indexPath.row];
		cell.textLabel.text = [NSString stringWithFormat:@"%@:", fee.name];
		cell.detailTextLabel.text = [formatter stringFromNumber: [NSNumber numberWithFloat:fee.cost]];			
	} else if (indexPath.section == 3 || (indexPath.section == 2 && ![self hasFees])) {
        cell.textLabel.text = @"View Customer's Purchase History";
        cell.detailTextLabel.text = @"";
    } else {
		// Cost Breakdown
		if (indexPath.row == 0) {
			cell.textLabel.text = @"Subtotal:";
			cell.detailTextLabel.text = [formatter stringFromNumber: [NSNumber numberWithFloat:_sale.subtotal]];
		} else if (indexPath.row == 1) {
			cell.textLabel.text = @"Taxes:";
			cell.detailTextLabel.text = [formatter stringFromNumber: [NSNumber numberWithFloat:_sale.tax]];
		} else {
			cell.textLabel.text = @"Total:";
			cell.detailTextLabel.text = [formatter stringFromNumber: [NSNumber numberWithFloat:_sale.total]];
		}
	}
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"Details";
		case 1:
			return [self hasFees] ? @"Fees" : @"Totals";
		case 2:
			return [self hasFees] ? @"Totals" : @"";
		default:
			return @"";
	}
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 3 || (indexPath.section == 2 && ![self hasFees])) {
        EDDSalesSearchViewController *searchViewController = [[EDDSalesSearchViewController alloc] initWithCustomerEmail:_sale.email];
        [self.navigationController pushViewController:searchViewController animated:YES];
    }
}

- (BOOL)hasFees {
	return [_sale.fees count] > 0;
}

@end
