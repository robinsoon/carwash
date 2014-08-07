//
//  myMenuTableViewController.h
//  tabswashcars
//
//  Created by Robinpad on 14-7-29.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "washcarsAppDelegate.h"

@interface myMenuTableViewController : UITableViewController






@property (weak, nonatomic) IBOutlet UILabel *menuPoint;


@property (weak, nonatomic) IBOutlet UILabel *menuBonus;

@property (weak, nonatomic) IBOutlet UILabel *menuPayed;

@property (weak, nonatomic) IBOutlet UILabel *menuUnPay;

@property (weak, nonatomic) IBOutlet UILabel *menuCoupons;

@property (weak, nonatomic) IBOutlet UILabel *menuUnCommit;

@property (weak, nonatomic) IBOutlet UILabel *menuCommited;

@property (weak, nonatomic) IBOutlet UILabel *menuSign;

@property (weak, nonatomic) IBOutlet UILabel *menuCar;

@property (weak, nonatomic) IBOutlet UILabel *menuAboutwashcar;

@property (weak, nonatomic) IBOutlet UILabel *lbUsername;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;

@property (weak, nonatomic) IBOutlet UILabel *txtMoney;

@property (strong, nonatomic) NSString * withnoLogin;// 来自订单

@property (strong, nonatomic) NSString *userid;           //传入参数id
@property (strong, nonatomic) NSString *username;           //参数name
@property (nonatomic) double usermoney;
@property (nonatomic) double userpoints;
@property (strong, nonatomic) NSString * useremail;
@property (strong, nonatomic) NSString * userphone;
@property (strong, nonatomic) NSString * password;

@property (nonatomic) BOOL isQuitCurrent;           //退出登录

@end
