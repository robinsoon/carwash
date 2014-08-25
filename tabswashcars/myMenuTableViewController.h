//
//  myMenuTableViewController.h
//  tabswashcars
//
//  Created by Robinpad on 14-7-29.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "washcarsAppDelegate.h"
#import "NSString+URLEncoding.h"

@interface myMenuTableViewController : UITableViewController



//保存数据列表[表现层所依赖的内部数据集合]
@property (nonatomic,strong) NSMutableArray* listData;  //商品列表
//接收从服务器返回数据 Json包
@property (strong,nonatomic) NSMutableData *datas;

@property (strong, nonatomic) NSString * userbonus;

@property (strong, nonatomic) NSString * valid_bonus;

@property (strong, nonatomic) NSString * order_pay;

@property (strong, nonatomic) NSString * order_unpay;

@property (strong, nonatomic) NSString * valid_order_code;

@property (strong, nonatomic) NSString * order_code;

@property (strong, nonatomic) NSString *sign;

@property (strong, nonatomic) NSString *need_sign;

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
