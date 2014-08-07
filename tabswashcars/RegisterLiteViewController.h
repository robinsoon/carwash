//
//  RegisterLiteViewController.h
//  tabswashcars
//
//  Created by Robinpad on 14-7-3.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+URLEncoding.h"
#import "washcarsAppDelegate.h"
@interface RegisterLiteViewController : UIViewController


@property (weak, nonatomic) IBOutlet UITextField *txtPhone;
@property (weak, nonatomic) IBOutlet UITextField *txtCheckNum;

@property (weak, nonatomic) IBOutlet UIButton *btnSendCheckNum;

@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;

@property (strong, nonatomic) NSString *userID;

@property (strong, nonatomic) NSString *username;         //用户名
@property (strong, nonatomic) NSString *password;         //用户密码
@property (strong, nonatomic) NSString *phone;              //用户手机号
@property (nonatomic) double usermoney;
@property (nonatomic) double userpoints;

@property (strong, nonatomic) NSString *phoneCheckNum;
@property (nonatomic) BOOL isRegisted;           //是否注册

@property (nonatomic) BOOL isLogin;           //传入参数id
@property (nonatomic) BOOL isConnected;
@property (strong, nonatomic) NSString *PageReturn;           //登录结果
@property (nonatomic,strong) NSString *RegAction;  //注册动作(1验证手机，2发手机码，3注册)
@property (nonatomic) BOOL isAllowCheckCode;
@property (nonatomic) BOOL isAutoLogin;

@property (nonatomic) BOOL isDebug;           //预设参数，自动填写用户名和密码，节省测试时间

@property (strong, nonatomic) NSTimer *tickTimer;  //timer对象
@property (nonatomic) int Ticktimers;

//保存数据列表[表现层所依赖的内部数据集合]
@property (nonatomic,strong) NSMutableArray* listData;  //商品列表
//接收从服务器返回数据 Json包
@property (strong,nonatomic) NSMutableData *datas;

//开始请求Web Service
-(void)startRequest;



@end
