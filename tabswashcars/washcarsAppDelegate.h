//
//  washcarsAppDelegate.h
//  tabswashcars
//
//  Created by Robinpad on 14-5-9.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"
#import "Reachability.h"

@class AliPayViewController;
@class PayViewController;

//全局变量
static NSString * staticURL  = @"http://www.2345mall.com/"; //@"http://taotao400.com/";


@interface washcarsAppDelegate : UIResponder <UIApplicationDelegate, BMKGeneralDelegate>{
    UIWindow *window;
    UINavigationController *navigationController;
    
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) AliPayViewController *AliPayViewController;
@property (strong, nonatomic) PayViewController *payViewController;


@property (strong, nonatomic) NSString *iPs_URL; //请求数据接口模板--地址

@property BOOL isLogin;         //用户是否登录
@property BOOL isbusiness;      //用户是普通用户还是商户
@property BOOL isVIP;           //用户是会员

@property (strong, nonatomic) NSString *userid;           //用户id
@property (strong, nonatomic) NSString *username;         //用户名
@property (strong, nonatomic) NSString *password;         //用户密码
@property (strong, nonatomic) NSString *phone;              //用户手机号
@property (nonatomic) BOOL isAutoLogin;           //自动登录

@property (nonatomic) double usermoney;
@property (nonatomic) double userpoints;
@property (strong, nonatomic) NSString * useremail;
@property (strong, nonatomic) NSString * userphone;

@property (strong, nonatomic) NSString * orderidforcoupons; //订单下的优惠券

@property (strong, nonatomic) NSString * categorylist;         //服务类型筛选参数

//诊断网络连接
@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;

@property (nonatomic) BOOL isreachChanged;        //网络连接变更
@property (strong, nonatomic) NSString *reachStatus; //网络连接状态
//存档本地配置信息
- (void)saveUserDefaults;
//读取本地配置信息
- (void)readUserDefaults;
//读取某个参数
- (NSString*)readUserDefaults:(NSString*)getKey;

//修改某个参数
- (void)saveUserDefaults:(NSString*)ItemKey setValue:(NSString*)ParamValue;

- (void)showNotify:(NSString*)MessageContent HoldTimes:(double)holdseconds;
- (void)NetworkReachability;
- (void)LoadMapManger;

//统一存取用户数据
- (void)LoadConfig;
- (void)SaveConfig;

@end
