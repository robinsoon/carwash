//
//  AppDelegate.h
//  MQPDemo
//
//  Created by ChaoGanYing on 13-5-3.
//  Copyright (c) 2013年 RenFei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;
@class PayViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) PayViewController *payViewController;

@end
