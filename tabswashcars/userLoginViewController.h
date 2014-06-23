//
//  userLoginViewController.h
//  tabswashcars
//
//  Created by Robinpad on 14-6-9.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+URLEncoding.h"
#import "washcarsAppDelegate.h"
#import "UIButton+Bootstrap.h"

@interface userLoginViewController : UIViewController

@property (nonatomic) BOOL isDebug;           //预设参数，自动填写用户名和密码，节省测试时间

@property (weak, nonatomic) IBOutlet UITextField *txtUserName;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnOK;
@property (weak, nonatomic) IBOutlet UIButton *btnRegist;
@property (weak, nonatomic) IBOutlet UILabel *txtTitle;
@property (weak, nonatomic) IBOutlet UISwitch *swcAutoLogin;
@property (weak, nonatomic) IBOutlet UILabel *lbReturn;

@property (strong, nonatomic) NSString *userid;           //传入参数id
@property (strong, nonatomic) NSString *username;           //传入参数id
@property (strong, nonatomic) NSString *password;           //传入参数id
@property (nonatomic) double usermoney;
@property (nonatomic) double userpoints;
@property (strong, nonatomic) NSString * useremail;
@property (strong, nonatomic) NSString * userphone;

@property (nonatomic) BOOL isAutoLogin;           //传入参数id
@property (nonatomic) BOOL isLogin;           //传入参数id
@property (nonatomic) BOOL isConnected;
@property (strong, nonatomic) NSString *PageReturn;           //登录结果

//保存数据列表[表现层所依赖的内部数据集合]
@property (nonatomic,strong) NSMutableArray* listData;  //商品列表
//接收从服务器返回数据 Json包
@property (strong,nonatomic) NSMutableData *datas;

//开始请求Web Service
-(void)startRequest;

@end
