//
//  EDDLaunchController.m
//  EDDSalesTracker
//
//  Created by Sunny Ratilal on 26/08/2015.
//  Copyright © 2015 Easy Digital Downloads. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "EDDLaunchController.h"
#import "EDDSetupTextField.h"
#import "EDDPickerViewController.h"
#import "EDDSite.h"
#import "EDDSites.h"
#import "EDDSiteController.h"
#import "KeychainItemWrapper.h"

#import "UIColor+EDDUIColorCategory.h"
#import "UIImage+EDDUIImageCategory.h"

@interface EDDLaunchController () <UITextFieldDelegate, EDDPickerViewControllerDelegate>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, strong) UIImageView *logo;

@property (nonatomic, strong) NSArray *currencies;
@property (nonatomic, strong) NSArray *types;

@property (nonatomic, strong) UIPickerView *currencyPicker;

@property (nonatomic, strong) EDDSetupTextField *siteName;
@property (nonatomic, strong) EDDSetupTextField *siteURL;
@property (nonatomic, strong) EDDSetupTextField *apiKey;
@property (nonatomic, strong) EDDSetupTextField *token;
@property (nonatomic, strong) EDDSetupTextField *currency;
@property (nonatomic, strong) EDDSetupTextField *type;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *addSiteButton;

@property (nonatomic, strong) NSString *chosenCurrency;
@property (nonatomic, strong) NSString *chosenType;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) EDDSite *site;
@property (nonatomic) NSInteger nextSiteID;

@property (nonatomic, assign) CGFloat keyboardOffset;

@property (nonatomic) BOOL fromURL;
@property (nonatomic, strong) NSDictionary *queryParams;

@end

@implementation EDDLaunchController

- (instancetype)initWithQuery:(NSDictionary *)query
{
    self = [super init];
    if (self) {
        self.fromURL = YES;
        self.queryParams = query;
    }
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor EDDBlueColor];
    
    [self addContainerView];
    [self addLogo];
    [self setupFields];
    [self layoutViewWithY:100.0f];
    
    if (self.fromURL) {
        [self autoFill];
    }
    
    NSInteger lastSiteID = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastSiteID"];
    if (lastSiteID) {
        self.nextSiteID = lastSiteID + 1;
    } else {
        self.nextSiteID = 1;
    }
    
    self.currencies = [NSArray arrayWithObjects: @"USD",	@"AFN",	@"ALL",	@"ANG",	@"ARS",	@"AUD",	@"AWG",	@"AZN",	@"BAM",	@"BBD",	@"BGN",	@"BMD",	@"BND",	@"BOB",	@"BRL",	@"BSD",	@"BWP",	@"BYR",	@"BZD",	@"CAD",	@"CHF",	@"CLP",	@"CNY",	@"COP",	@"CRC",	@"CUP",	@"CZK",	@"DKK",	@"DOP",	@"EEK",	@"EGP",	@"EUR",	@"FJD",	@"FKP",	@"GBP",	@"GGP",	@"GHC",	@"GIP",	@"GTQ",	@"GYD",	@"HKD",	@"HNL",	@"HRK",	@"HUF",	@"IDR",	@"ILS",	@"IMP",	@"INR",	@"IRR",	@"ISK",	@"JEP",	@"JMD",	@"JPY",	@"KGS",	@"KHR",	@"KPW",	@"KRW",	@"KYD",	@"KZT",	@"LAK",	@"LBP",	@"LKR",	@"LRD",	@"LTL",	@"LVL",	@"MKD",	@"MNT",	@"MUR",	@"MXN",	@"MYR",	@"MZN",	@"NAD",	@"NGN",	@"NIO",	@"NOK",	@"NPR",	@"NZD",	@"OMR",	@"PAB",	@"PEN",	@"PHP",	@"PKR",	@"PLN",	@"PYG",	@"QAR",	@"RON",	@"RSD",	@"RUB",	@"SAR",	@"SBD",	@"SCR",	@"SEK",	@"SGD",	@"SHP",	@"SOS",	@"SRD",	@"SVC",	@"SYP",	@"THB",	@"TRL",	@"TRY",	@"TTD",	@"TVD",	@"TWD",	@"UAH",	@"UYU",	@"UZS",	@"VEF",	@"VND",	@"XCD",	@"YER",	@"ZAR",	@"ZWD", nil];
    self.types = [NSArray arrayWithObjects: @"Standard", @"Commission Only", @"Standard + Commission", @"Standard + Store", nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}

- (void)addContainerView
{
    NSAssert(self.view, @"The view should be loaded by now");
    
    UIView *containerView = [[UIView alloc] initWithFrame:self.view.bounds];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

//    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapGestureAction:)];
//    gestureRecognizer.numberOfTapsRequired = 1;
//    gestureRecognizer.cancelsTouchesInView = YES;
//    [containerView addGestureRecognizer:gestureRecognizer];
    
    // Attach + Keep the Reference
    [self.view addSubview:containerView];
    self.containerView = containerView;
//    self.tapGestureRecognizer = gestureRecognizer;
}

- (void)addLogo
{
    NSAssert(self.view, @"The view should be loaded by now");
    
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"edd-white"]];
    logo.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;

    [self.containerView addSubview:logo];

    self.logo = logo;
}

- (void)setupFields
{
    NSAssert(self.view, @"The view should be loaded by now");
    
    // Site Name
    EDDSetupTextField *siteName = [[EDDSetupTextField alloc] init];
    siteName.tag = 1;
    siteName.backgroundColor = [UIColor whiteColor];
    siteName.placeholder = NSLocalizedString(@"Site Name", nil);
    siteName.adjustsFontSizeToFitWidth = YES;
    siteName.returnKeyType = UIReturnKeyNext;
    siteName.delegate = self;
    siteName.keyboardAppearance = UIKeyboardAppearanceDark;
    siteName.autocorrectionType = UITextAutocorrectionTypeNo;
    siteName.autocapitalizationType = UITextAutocapitalizationTypeWords;
    siteName.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    siteName.accessibilityIdentifier = @"Site Name";
    siteName.isFirstInSection = YES;
    
    // Site URL
    EDDSetupTextField *siteURL = [[EDDSetupTextField alloc] init];
    siteURL.tag = 2;
    siteURL.backgroundColor = [UIColor whiteColor];
    siteURL.placeholder = NSLocalizedString(@"Site Address (URL)", nil);
    siteURL.adjustsFontSizeToFitWidth = YES;
    siteURL.returnKeyType = UIReturnKeyNext;
    siteURL.delegate = self;
    siteURL.keyboardType = UIKeyboardTypeURL;
    siteURL.keyboardAppearance = UIKeyboardAppearanceDark;
    siteURL.autocorrectionType = UITextAutocorrectionTypeNo;
    siteURL.autocapitalizationType = UITextAutocapitalizationTypeNone;
    siteURL.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    siteURL.accessibilityIdentifier = @"Site Address (URL)";
    
    // API Key
    EDDSetupTextField *apiKey = [[EDDSetupTextField alloc] init];
    apiKey.tag = 3;
    apiKey.backgroundColor = [UIColor whiteColor];
    apiKey.placeholder = NSLocalizedString(@"API Key", nil);
    apiKey.adjustsFontSizeToFitWidth = YES;
    apiKey.returnKeyType = UIReturnKeyNext;
    apiKey.delegate = self;
    apiKey.keyboardAppearance = UIKeyboardAppearanceDark;
    apiKey.autocorrectionType = UITextAutocorrectionTypeNo;
    apiKey.autocapitalizationType = UITextAutocapitalizationTypeNone;
    apiKey.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    apiKey.accessibilityIdentifier = @"API Key";
    
    // Token
    EDDSetupTextField *token = [[EDDSetupTextField alloc] init];
    token.tag = 4;
    token.backgroundColor = [UIColor whiteColor];
    token.placeholder = NSLocalizedString(@"Token", nil);
    token.adjustsFontSizeToFitWidth = YES;
    token.returnKeyType = UIReturnKeyNext;
    token.delegate = self;
    token.keyboardAppearance = UIKeyboardAppearanceDark;
    token.autocorrectionType = UITextAutocorrectionTypeNo;
    token.autocapitalizationType = UITextAutocapitalizationTypeNone;
    token.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    token.accessibilityIdentifier = @"Token";
    
    // Currency
    EDDSetupTextField *currency = [[EDDSetupTextField alloc] init];
    currency.tag = 5;
    currency.backgroundColor = [UIColor whiteColor];
    currency.placeholder = NSLocalizedString(@"Currency", nil);
    currency.adjustsFontSizeToFitWidth = YES;
    currency.returnKeyType = UIReturnKeyNext;
    currency.delegate = self;
    currency.keyboardAppearance = UIKeyboardAppearanceDark;
    currency.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    currency.accessibilityIdentifier = @"Currency";
    
    // Type
    EDDSetupTextField *type = [[EDDSetupTextField alloc] init];
    type.tag = 6;
    type.backgroundColor = [UIColor whiteColor];
    type.placeholder = NSLocalizedString(@"Type of Site", nil);
    type.adjustsFontSizeToFitWidth = YES;
    type.returnKeyType = UIReturnKeyNext;
    type.delegate = self;
    type.keyboardAppearance = UIKeyboardAppearanceDark;
    type.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    type.accessibilityIdentifier = @"Type of Site";
    
    // Status Label
    UILabel *statusLabel = [[UILabel alloc] init];
    statusLabel.textColor = [UIColor whiteColor];
    statusLabel.textAlignment = NSTextAlignmentCenter;
    statusLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    statusLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    
    // Add Site Button
    UIButton *addSiteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addSiteButton addTarget:self action:@selector(addSiteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [addSiteButton setTitle:@"Add Site" forState:UIControlStateNormal];
    [addSiteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addSiteButton setTitleColor:[UIColor EDDBlueColor] forState:UIControlStateHighlighted];
    [addSiteButton setBackgroundColor:[UIColor clearColor]];
    [addSiteButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
    [addSiteButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    [[addSiteButton layer] setBorderWidth:1.0f];
    [[addSiteButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    addSiteButton.layer.cornerRadius = 2;
    addSiteButton.enabled = false;
    [[addSiteButton layer] setOpacity:0.3f];
    addSiteButton.clipsToBounds = YES;
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    [self.containerView addSubview:siteName];
    [self.containerView addSubview:siteURL];
    [self.containerView addSubview:apiKey];
    [self.containerView addSubview:token];
    [self.containerView addSubview:currency];
    [self.containerView addSubview:type];
    [self.containerView addSubview:statusLabel];
    [self.containerView addSubview:addSiteButton];
    [self.containerView addSubview:self.activityIndicator];
    
    self.siteName = siteName;
    self.siteURL = siteURL;
    self.apiKey = apiKey;
    self.token = token;
    self.currency = currency;
    self.type = type;
    self.addSiteButton = addSiteButton;
    
    self.statusLabel = statusLabel;
}

- (void)layoutViewWithY:(CGFloat)y
{
    CGSize textFieldSize;
    if (IS_IPHONE_5_SCREEN) {
        textFieldSize = CGSizeMake(300.0, 44.0);
    } else {
        textFieldSize = CGSizeMake(320.0, 44.0);
    }
    
    CGFloat offset = 30.0;
    
    CGFloat viewWidth = CGRectGetWidth(self.view.bounds);
    
    CGFloat textFieldX = (viewWidth - textFieldSize.width) * 0.5f;
    
    CGFloat logoX = (viewWidth - CGRectGetWidth(self.logo.frame)) * 0.5f;
    self.logo.frame = CGRectIntegral(CGRectMake(logoX, y, CGRectGetWidth(self.logo.frame), CGRectGetHeight(self.logo.frame)));
    
    self.siteName.frame = CGRectIntegral(CGRectMake(textFieldX, CGRectGetMaxY(self.logo.frame) + offset, textFieldSize.width, textFieldSize.height));
    self.siteURL.frame = CGRectIntegral(CGRectMake(textFieldX, CGRectGetMaxY(self.siteName.frame) - 1.0, textFieldSize.width, textFieldSize.height));
    self.apiKey.frame = CGRectIntegral(CGRectMake(textFieldX, CGRectGetMaxY(self.siteURL.frame) - 1.0, textFieldSize.width, textFieldSize.height));
    self.token.frame = CGRectIntegral(CGRectMake(textFieldX, CGRectGetMaxY(self.apiKey.frame) - 1.0, textFieldSize.width, textFieldSize.height));
    self.currency.frame = CGRectIntegral(CGRectMake(textFieldX, CGRectGetMaxY(self.token.frame) - 1.0, textFieldSize.width, textFieldSize.height));
    self.type.frame = CGRectIntegral(CGRectMake(textFieldX, CGRectGetMaxY(self.currency.frame) - 1.0, textFieldSize.width, textFieldSize.height));
    self.addSiteButton.frame = CGRectIntegral(CGRectMake(textFieldX, CGRectGetMaxY(self.type.frame) + 30.0, textFieldSize.width, textFieldSize.height));
    
    self.statusLabel.frame = CGRectIntegral(CGRectMake(textFieldX, CGRectGetMaxY(self.addSiteButton.frame) + 30.0, textFieldSize.width, textFieldSize.height));
    
    self.activityIndicator.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2, CGRectGetMaxY(self.addSiteButton.frame) + 30.0);
}

- (void)autoFill
{
    self.siteName.text = [self.queryParams objectForKey:@"sitename"];
    self.siteURL.text = [self.queryParams objectForKey:@"siteurl"];
    self.apiKey.text = [self.queryParams objectForKey:@"key"];
    self.token.text = [self.queryParams objectForKey:@"token"];
    self.currency.text = [NSString stringWithFormat:@"Currency: %@", [self.queryParams objectForKey:@"currency"]];
}

- (void)addSiteButtonPressed:(id)sender
{
    [self.activityIndicator startAnimating];
    self.addSiteButton.enabled = false;
    [[self.addSiteButton layer] setOpacity:0.3f];
    
    __block EDDLaunchController *weakSelf = self;
    
    NSURL *apiTestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/edd-api/sales?key=%@&token=%@", self.siteURL.text, self.apiKey.text, self.token.text]];
    NSURLRequest *request = [NSURLRequest requestWithURL:apiTestURL];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
        NSUInteger statusCode = httpURLResponse.statusCode;
        if (statusCode != 200) {
            [weakSelf apiTestError];
        } else {
            [weakSelf apiTestSuccess];
        }
    }];
    [task resume];
}

- (void)apiTestError
{
    dispatch_async(dispatch_get_main_queue(), ^() {
        self.statusLabel.text = NSLocalizedString(@"Error Connecting to API...", @"");
        [self shakeAnimation:self.statusLabel];
        [self.activityIndicator stopAnimating];
    });
}

- (void)apiTestSuccess
{
    dispatch_async(dispatch_get_main_queue(), ^() {
        self.statusLabel.text = NSLocalizedString(@"Connection Made Successfully.", @"");
        [self.activityIndicator stopAnimating];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"EDD_Site_%ld", (long) self.nextSiteID]];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent: @"sites.eddsites"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        BOOL isDir = NO;
        
        if (![fileManager fileExistsAtPath:folderPath isDirectory:&isDir] && isDir == NO) {
            [fileManager createDirectoryAtPath:folderPath
                   withIntermediateDirectories:NO
                                    attributes:nil
                                         error:&error];
        }

        EDDSites *sites = [[EDDSites alloc] init];
        NSMutableArray *siteObjects = [NSMutableArray array];
        
        self.site = [[EDDSite alloc] init];
        self.site.siteName = self.siteName.text;
        self.site.siteURL = self.siteURL.text;
        self.site.currency = self.chosenCurrency;
        self.site.type = self.chosenType;
        self.site.siteID = self.nextSiteID;
        
        if ([self.chosenType isEqualToString:@"Standard"]) {
            self.site.siteType = EDDStandard;
        } else if ([self.chosenType isEqualToString:@"Standard + Commission"]) {
            self.site.siteType = EDDStandardAndCommission;
        } else if ([self.chosenType isEqualToString:@"Commission Only"]) {
            self.site.siteType = EDDCommission;
        } else {
            self.site.siteType = EDDStandardAndStore;
        }
        
        NSArray *dashboardOrder;
        
        switch (self.site.siteType) {
            case EDDStandardAndCommission:
            case EDDStandard:
                dashboardOrder = @[@(EDDSales), @(EDDEarnings), @(EDDCommissions), @(EDDReviews)];
                break;
            case EDDStandardAndStore:
                dashboardOrder = @[@(EDDSales), @(EDDEarnings), @(EDDCommissions), @(EDDStoreCommissions), @(EDDReviews)];
                break;
            case EDDCommission:
                dashboardOrder = @[@(EDDCommissions)];
                break;
            default:
                break;
        }
        
        self.site.dashboardOrder = dashboardOrder;

        [siteObjects addObject:self.site];
        
        sites.sites = siteObjects;
        [NSKeyedArchiver archiveRootObject:sites toFile:filePath];
        
        self.site.apiKey = self.apiKey.text;
        self.site.token = self.token.text;
        
        KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[NSString stringWithFormat:@"edd-site-%ld", (long)self.nextSiteID] accessGroup:nil];
        [keychain setObject:self.apiKey.text forKey:(__bridge NSString *)kSecAttrAccount];
        [keychain setObject:self.token.text forKey:(__bridge NSString *)kSecValueData];
        
        if (![[NSUserDefaults standardUserDefaults] integerForKey:@"defaultSiteID"]) {
            [[NSUserDefaults standardUserDefaults] setInteger:self.site.siteID forKey:@"defaultSiteID"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        EDDSiteController *siteController = [[EDDSiteController alloc] initWithSite:self.site];

        [UIView animateWithDuration:0.6f
                         animations:^{
                             self.view.frame = CGRectMake(0, -(self.view.frame.size.height), self.view.frame.size.width, self.view.frame.size.height);
                             [self presentViewController:siteController animated:YES completion:nil];
                         }];
    });
}

- (void)shakeAnimation:(UILabel*) label
{
    CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
    [shake setDuration:0.1];
    [shake setRepeatCount:5];
    [shake setAutoreverses:YES];
    [shake setFromValue:[NSValue valueWithCGPoint:CGPointMake(label.center.x - 10,label.center.y)]];
    [shake setToValue:[NSValue valueWithCGPoint:CGPointMake(label.center.x + 10, label.center.y)]];
    [label.layer addAnimation:shake forKey:@"position"];
}

- (BOOL)validateInputs
{
    BOOL valid = false;
    
    if ([self.siteName hasText] && [self.siteURL hasText] && [self.apiKey hasText] && [self.token hasText] && [self.currency hasText] && [self.type hasText]) {
        valid = true;
    }
    
    return valid;
}

#pragma mark - Keyboard Handling

- (void)keyboardWillShow:(NSNotification *)notification
{
    [UIView animateWithDuration:0.4f
                     animations:^{
                         if (IS_IPHONE_5_SCREEN) {
                             [self layoutViewWithY:-65.0f];
                         } else {
                             [self layoutViewWithY:20.0f];
                         }
                     }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.4f
                     animations:^{
                         [self layoutViewWithY:100.0f];
                     }];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag + 1;
    UIResponder *nextResponder = [textField.superview viewWithTag:nextTag];
    
    if (nextResponder && nextTag < 5) {
        [nextResponder becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextView *)textView
{
    if (textView.tag == 5) {
        EDDPickerViewController *pickerViewController = [[EDDPickerViewController alloc] init];
        pickerViewController.delegate = self;
        pickerViewController.navBarTitle = NSLocalizedString(@"Select a Currency", @"");
        pickerViewController.rows = self.currencies;
        pickerViewController.tag = 5;
        pickerViewController.view.backgroundColor = [UIColor clearColor];
        pickerViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        pickerViewController.modalPresentationCapturesStatusBarAppearance = YES;
        [self presentViewController:pickerViewController animated:YES completion:nil];
        return NO;
    }
    
    if (textView.tag == 6) {
        EDDPickerViewController *pickerViewController = [[EDDPickerViewController alloc] init];
        pickerViewController.navBarTitle = NSLocalizedString(@"Select the Type of Site", @"");
        pickerViewController.delegate = self;
        pickerViewController.rows = self.types;
        pickerViewController.tag = 6;
        pickerViewController.view.backgroundColor = [UIColor clearColor];
        pickerViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        pickerViewController.modalPresentationCapturesStatusBarAppearance = YES;
        [self presentViewController:pickerViewController animated:YES completion:nil];
        return NO;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self validateInputs]) {
        [[self.addSiteButton layer] setOpacity:1.0f];
        self.addSiteButton.enabled = true;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - EDDPickerViewControllerDelegate

- (void)didSelectRow:(NSString *)text tag:(int)tag;
{
    if (tag == 5) {
        self.currency.text = [NSString stringWithFormat:@"Currency: %@", text];
        self.chosenCurrency = text;
    } else if (tag == 6) {
        self.type.text = [NSString stringWithFormat:@"Type: %@", text];
        self.chosenType = text;
    }
    
    if ([self validateInputs]) {
        [[self.addSiteButton layer] setOpacity:1.0f];
        self.addSiteButton.enabled = true;
    }
}

@end