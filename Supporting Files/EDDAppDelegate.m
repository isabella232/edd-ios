//
//  AppDelegate.m
//  EDDSalesTracker
//
//  Created by Matthew Strickland on 3/7/13.
//  Copyright (c) 2013 Easy Digital Downloads. All rights reserved.
//

#import "GAI.h"
#import "KeychainItemWrapper.h"

#import "EDDAppDelegate.h"
#import "EDDAppDefines.h"
#import "EDDLaunchController.h"
#import "EDDSiteController.h"
#import "EDDSites.h"
#import "EDDSite.h"
#import "EDDNetworkService.h"

#import "UIColor+EDDUIColorCategory.h"
#import "Reachability.h"

static NSString *const kTrackingId = @"UA-52425914-1";

@interface EDDAppDelegate ()

@property (nonatomic, strong) Reachability *internetReachability;
@property (nonatomic, assign) BOOL okToWait;
@property (nonatomic, copy) void (^dispatchHandler)(GAIDispatchResult result);

@end

@implementation EDDAppDelegate

+ (EDDAppDelegate *)sharedEDDAppDelegate
{
    return (EDDAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor clearColor];
    
    NSLog(@"File Directory: %@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
    
    // Setup Caching
    NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:8 * 1024 * 1024 diskCapacity:20 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:cache];
    
    [self globalAppearance];
    
    [self setupReachability];
    
    [GAI sharedInstance].dispatchInterval = 120;
    self.tracker = [[GAI sharedInstance] trackerWithTrackingId:kTrackingId];
    
    if ([self noSitesSetup]) {
        EDDLaunchController *rootViewController = [[EDDLaunchController alloc] init];
        self.window.rootViewController = rootViewController;
    } else {
        EDDSite *site = [self fetchDefaultSite];
        EDDNetworkService *networkService = [EDDNetworkService sharedInstance];
        networkService.site = site;
        EDDSiteController *siteController = [[EDDSiteController alloc] initWithSite:site];
        self.window.rootViewController = siteController;
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[self.window makeKeyAndVisible];
	
    if (![self noSitesSetup]) {
        [self setup3DTouch];
    }
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self sendHitsInBackground];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
{
    if ([[url scheme] isEqualToString:@"eddwp"]) {
        NSDictionary *query = [self parseQueryString:[url query]];
        EDDLaunchController *launchController = [[EDDLaunchController alloc] initWithQuery:query];
        self.window.rootViewController = launchController;
        [self.window makeKeyAndVisible];
    }
    
    return NO;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self sendHitsInBackground];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    // Purge the shared cache when there's a memory warning
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    
}

#pragma mark - Private Methods

- (void)sendHitsInBackground
{
    self.okToWait = YES;
    __weak EDDAppDelegate *weakSelf = self;
    __block UIBackgroundTaskIdentifier backgroundTaskId =
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        weakSelf.okToWait = NO;
    }];
    
    if (backgroundTaskId == UIBackgroundTaskInvalid) {
        return;
    }
    
    self.dispatchHandler = ^(GAIDispatchResult result) {
        if (result == kGAIDispatchGood && weakSelf.okToWait ) {
            [[GAI sharedInstance] dispatchWithCompletionHandler:weakSelf.dispatchHandler];
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
        }
    };
    [[GAI sharedInstance] dispatchWithCompletionHandler:self.dispatchHandler];
}

- (void)setup3DTouch
{
    UIApplicationShortcutIcon *dashboardIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"QuickActionDashboard"];
    UIApplicationShortcutIcon *salesIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"QuickActionSales"];
    UIApplicationShortcutIcon *customersIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"QuickActionCustomers"];
    UIApplicationShortcutIcon *reportsIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"QuickActionReports"];
    
    UIApplicationShortcutItem *dashboard = [[UIApplicationShortcutItem alloc] initWithType:@"edd.dashboard" localizedTitle:@"Dashboard" localizedSubtitle:nil icon:dashboardIcon userInfo:nil];
    UIApplicationShortcutItem *sales = [[UIApplicationShortcutItem alloc] initWithType:@"edd.sales" localizedTitle:@"Sales" localizedSubtitle:nil icon:salesIcon userInfo:nil];
    UIApplicationShortcutItem *customers = [[UIApplicationShortcutItem alloc] initWithType:@"edd.customers" localizedTitle:@"Customers" localizedSubtitle:nil icon:customersIcon userInfo:nil];
    UIApplicationShortcutItem *reports = [[UIApplicationShortcutItem alloc] initWithType:@"edd.reports" localizedTitle:@"Reports" localizedSubtitle:nil icon:reportsIcon userInfo:nil];
    
    [UIApplication sharedApplication].shortcutItems = @[dashboard, sales, customers, reports];
}

- (void)globalAppearance {
    UINavigationBar *navigationBar = [UINavigationBar appearance];
    
    [navigationBar setBackgroundImage:[[UIImage alloc] init]
                                      forBarPosition:UIBarPositionAny
                                          barMetrics:UIBarMetricsDefault];
    
    [navigationBar setShadowImage:[[UIImage alloc] init]];
    
    [navigationBar setTranslucent:NO];
    [navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    [navigationBar setTintColor:[UIColor whiteColor]];
    [navigationBar setBarTintColor:[UIColor EDDBlueColor]];
    [navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

- (BOOL)noSitesSetup
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *sitesPath = [documentsDirectory stringByAppendingPathComponent: @"sites.eddsites"];
    BOOL siteDataExists = [[NSFileManager defaultManager] fileExistsAtPath:sitesPath];
    
    if (![[NSUserDefaults standardUserDefaults] integerForKey:@"defaultSiteID"] || siteDataExists == NO) {
        return YES;
    } else {
        return NO;
    }
}

- (NSDictionary *)parseQueryString:(NSString *)query {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByRemovingPercentEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByRemovingPercentEncoding];
        
        [dict setObject:val forKey:key];
    }
    return dict;
}

- (NSInteger)getDefaultSiteID
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"defaultSiteID"];
}

- (EDDSite *)fetchDefaultSite
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *sitesPath = [documentsDirectory stringByAppendingPathComponent: @"sites.eddsites"];
    EDDSites *sites = [NSKeyedUnarchiver unarchiveObjectWithFile:sitesPath];
    NSMutableArray *siteObjects = sites.sites;
    
    EDDSite *siteObject = [[EDDSite alloc] init];
    
    for (EDDSite *site in siteObjects) {
        if (site.siteID == [self getDefaultSiteID]) {
            siteObject = site;
        }
    }
    
    KeychainItemWrapper* keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[NSString stringWithFormat:@"edd-site-%ld", (long)[self getDefaultSiteID]] accessGroup:nil];
    siteObject.apiKey = [keychain objectForKey:(__bridge NSString *)kSecAttrAccount];
    siteObject.token =  [keychain objectForKey:(__bridge NSString *)kSecValueData];
    
    return siteObject;
}

- (void)setupReachability
{
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    
    [self.internetReachability startNotifier];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    CGPoint location = [[[event allTouches] anyObject] locationInView:[self window]];
    
    if (location.y > 0 && location.y < 20) {
        [self touchStatusBar];
    }
}

- (void)touchStatusBar
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"touchStatusBarTap" object:nil];
}

@end