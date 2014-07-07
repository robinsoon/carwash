//
//  myInforTableViewController.h
//  tabswashcars
//
//  Created by Robinpad on 14-6-9.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "NSString+URLEncoding.h"
#import "UIImageView+WebCache.h"

#import "washcarsAppDelegate.h"

#import "CouponsViewCell.h"
#import "couponsDetailViewController.h"


@interface couponsTableViewController : UITableViewController
//保存数据列表[表现层所依赖的内部数据集合]
@property (nonatomic,strong) NSMutableArray* listData;  //商品列表

@property (nonatomic,strong) NSMutableArray* listSort;  //排序列表

@property (nonatomic,strong) NSMutableArray* listArea;  //地区列表

//接收从服务器返回数据 Json包
@property (strong,nonatomic) NSMutableData *datas;

//自定义风格的单元格
@property (strong,nonatomic) couponsDetailViewController *serviceDetail;

@property (strong, nonatomic) NSString *userid;           //传入参数id
@property (strong, nonatomic) NSString *username;           //参数name
@property (nonatomic) double usermoney;
@property (nonatomic) double userpoints;
@property (strong, nonatomic) NSString * useremail;
@property (strong, nonatomic) NSString * userphone;

@property (weak, nonatomic) IBOutlet UILabel *lbUsername;
@property (weak, nonatomic) IBOutlet UILabel *lbUserInfo;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnAbout;
@property (weak, nonatomic) IBOutlet UIButton *btnmyCoupons;
@property (weak, nonatomic) IBOutlet UILabel *txtMoney;
@property (weak, nonatomic) IBOutlet UILabel *txtPoint;

@property (strong, nonatomic) NSString * orderID;   //订单ID

@property (strong, nonatomic) NSString * orderName;   //订单名称
@property (strong, nonatomic) NSString * Address;
@property (strong, nonatomic) NSString * Phone;

@property (nonatomic) CLLocationCoordinate2D Locationpt; //初始坐标位置
@property (strong, nonatomic) NSString * FromOrder;// 来自订单

@property (strong, nonatomic) NSString * withnoLogin;// 来自订单

@property (nonatomic) BOOL isQuitCurrent;           //退出登录
@property (strong, nonatomic)UIColor *CellBgColor;  //单元格背景色

//重新加载表视图
-(void)reloadView:(NSDictionary*)res;

//开始请求 Web Service
-(void)startRequest;

//翻页
- (int)setPageNext;
@end
