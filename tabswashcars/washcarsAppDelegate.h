//
//  washcarsAppDelegate.h
//  tabswashcars
//
//  Created by Robinpad on 14-5-9.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"
@class AliPayViewController;
@class PayViewController;

@interface washcarsAppDelegate : UIResponder <UIApplicationDelegate, BMKGeneralDelegate>{
    UIWindow *window;
    UINavigationController *navigationController;
    
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) AliPayViewController *AliPayViewController;
@property (strong, nonatomic) PayViewController *payViewController;

@end
