//
//  AppDelegate.m
//  Liberty Bell
//
//  Created by Lehel Medves on 5/24/13.
//  Copyright (c) 2013 Lehel Medves. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
       self.viewController = [[ViewController alloc] initWithNibName:@"ViewController-Ipad" bundle:nil];
    }
    else {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    }
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    [Flurry startSession:@"X4HBSDBSXZ5WCN7XBRQM"];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    Chartboost *cb = [Chartboost sharedChartboost];
    
    cb.appId = @"524ad9b716ba47d51c000009";
    cb.appSignature = @"3d31f075496424ae98aa403b84adfe3996bec1da";
    
    // Begin a user session. Must not be dependent on user actions or any prior network requests.
    [cb startSession];    
    // Show an interstitial
    [cb showInterstitial];
    
    [self.viewController giveFreeCredits];
}

- (BOOL)shouldRequestInterstitialsInFirstSession
{
    return NO;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
