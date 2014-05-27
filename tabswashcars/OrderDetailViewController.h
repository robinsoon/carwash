//
//  OrderDetailViewController.h
//  tabswashcars
//
//  Created by Robinpad on 14-5-16.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+URLEncoding.h"
@interface OrderDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;

@property (weak, nonatomic) IBOutlet UILabel *lbID;
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UILabel *lbPrice;
@property (weak, nonatomic) IBOutlet UILabel *lbDescription;
@property (weak, nonatomic) IBOutlet UILabel *lbAmount;
@property (weak, nonatomic) IBOutlet UILabel *lbOrderStatus;
@property (weak, nonatomic) IBOutlet UILabel *lbPayStatus;

@property (strong, nonatomic) NSString *itemid;           //传入参数id

@property (nonatomic,strong) NSString *itemname;  //商品名称
@property (nonatomic,strong) NSString *itemdetail;  //商品详情数据
@property (nonatomic,strong) NSString *itemprice;  //商品价格
@property (nonatomic,strong) NSString *itemAmount;  //商品数量

@property (nonatomic,strong) NSString *OrderAction;  //订单动作(新建，付款，完成)
@property (nonatomic,strong) NSString *OrderID;  //订单编号
@property (nonatomic,strong) NSString *UserID;   //用户编号
@property (nonatomic,strong) NSString *OrderStatus;   //订单状态
@property (nonatomic,strong) NSString *PayStatus;   //支付状态

//保存数据列表[表现层所依赖的内部数据集合]
@property (nonatomic,strong) NSMutableArray* listData;  //商品列表

//接收从服务器返回数据 Json包
@property (strong,nonatomic) NSMutableData *datas;

//重新加载表视图
-(void)reloadView:(NSDictionary*)res;

//开始请求Web Service
-(void)startRequest;

//翻页
- (int)setPageNext;
@end
