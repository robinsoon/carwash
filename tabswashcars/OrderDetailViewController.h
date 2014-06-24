//
//  OrderDetailViewController.h
//  tabswashcars
//
//  Created by Robinpad on 14-5-16.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+URLEncoding.h"
#import "washcarsAppDelegate.h"


@interface OrderDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;
@property (weak, nonatomic) IBOutlet UIButton *btnCreate;
@property (weak, nonatomic) IBOutlet UIButton *btnRebackOrder;
@property (weak, nonatomic) IBOutlet UIButton *btnDeleteOrder;
@property (weak, nonatomic) IBOutlet UIButton *btnBuyAgain;

@property (weak, nonatomic) IBOutlet UIButton *btnRefresh;


@property (weak, nonatomic) IBOutlet UILabel *lbID;
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UILabel *lbPrice;//商品单价
@property (weak, nonatomic) IBOutlet UITextView *lbDescription;
@property (weak, nonatomic) IBOutlet UILabel *lbAmount;
@property (weak, nonatomic) IBOutlet UILabel *lbOrderStatus;
@property (weak, nonatomic) IBOutlet UILabel *lbPayStatus;
@property (weak, nonatomic) IBOutlet UILabel *lbTotalPrice;//商品总价
@property (weak, nonatomic) IBOutlet UIStepper *btnstep;

@property (weak, nonatomic) IBOutlet UITextField *lbBuyCount;
@property (weak, nonatomic) IBOutlet UILabel *lbidtext;
@property (weak, nonatomic) IBOutlet UIButton *btncoupons;

@property (weak, nonatomic) IBOutlet UILabel *lbOrderDate;
@property (weak, nonatomic) IBOutlet UILabel *lbOrderDatehead;

@property (strong, nonatomic) NSString *itemid;           //传入参数id

@property (nonatomic,strong) NSString *itemname;  //商品名称
@property (nonatomic,strong) NSString *itemdetail;  //商品详情数据
@property (nonatomic,strong) NSString *itemprice;  //商品单价
@property (nonatomic,strong) NSString *itemAmount;  //商品数量
@property (nonatomic,strong) NSString *itemTotal;  //商品总价

@property (nonatomic,strong) NSString *OrderAction;  //订单动作(新建，付款，完成)
@property (nonatomic,strong) NSString *OrderID;  //订单编号
@property (nonatomic,strong) NSString *Ordersn;  //订单编号
@property (nonatomic,strong) NSString *UserID;   //用户编号
@property (nonatomic,strong) NSString *OrderStatus;   //订单状态
@property (nonatomic,strong) NSString *PayStatus;   //支付状态

@property (nonatomic,strong) NSString *PayID;   //支付编号
@property (nonatomic,strong) NSString *PayName;   //支付编号
@property (nonatomic,strong) NSString *OrderDate;   //订单日期

@property (strong, nonatomic) NSString *PageAction;           //页面动作[主要用于第一次刷新]
//保存数据列表[表现层所依赖的内部数据集合]
@property (nonatomic,strong) NSMutableArray* listData;  //商品列表

//接收从服务器返回数据 Json包
@property (strong,nonatomic) NSMutableData *datas;

//订单详情[包含3部分]
@property (strong,nonatomic) NSDictionary *dict_orderdetails;

@property (nonatomic) CLLocationCoordinate2D Locationpt; //初始坐标位置

//重新加载表视图
-(void)reloadView:(NSDictionary*)res;

//开始请求Web Service
-(void)startRequest;

//翻页
- (int)setPageNext;
@end
