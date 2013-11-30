//
//  AppDelegate.h
//  Liberty Bell
//
//  Created by Lehel Medves on 5/24/13.
//  Copyright (c) 2013 Lehel Medves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Flurry.h"
#import "Chartboost.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, ChartboostDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@end
