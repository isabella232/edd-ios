//
//  EDDSetupViewController.h
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/9/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "EDDBaseTableViewController.h"

#import "BButton.h"

@interface EDDSetupViewController : EDDBaseTableViewController<UITextFieldDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource> {
    BOOL keyboardShown;
    CGPoint point;
    CGRect keyboardRect;
    UITextField *activeTextField;
    UITapGestureRecognizer *tapRecognizer;
}

@property (nonatomic) IBOutlet BButton *saveButton;

@property (nonatomic) UITextField *siteName;
@property (nonatomic) UITextField *url;
@property (nonatomic) UITextField *apiKey;
@property (nonatomic) UITextField *token;
@property (nonatomic) NSString *currency;
@property (nonatomic) NSString *siteType;

@property (nonatomic) NSDictionary *siteForEditing;

@property (nonatomic, weak) IBOutlet UIView *footerView;

@property (nonatomic, strong) id editingField;

- (IBAction)saveSettings:(id)sender;

- (id)initForInitialSetup;
- (id)initForSiteCreation:(NSDictionary *)site;

@end
