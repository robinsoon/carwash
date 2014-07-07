//
//  ViewController.h
//  MQPDemo
//
//  Created by ChaoGanYing on 13-5-6.
//  Copyright (c) 2013年 Alipay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlixLibService.h"
#import "NSString+URLEncoding.h"
#import "washcarsAppDelegate.h"
@interface Product : NSObject{
@private
	float _price;
	NSString *_subject;
	NSString *_body;
	NSString *_orderId;
}

@property (nonatomic, assign) float price;
@property (nonatomic, retain) NSString *subject;
@property (nonatomic, retain) NSString *body;
@property (nonatomic, retain) NSString *orderId;

@end

@interface AliPayViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *_products;
    SEL _result;
}

@property (nonatomic,assign) SEL result;//这里声明为属性方便在于外部传入。
-(void)paymentResult:(NSString *)result;

@property (nonatomic,strong) NSMutableArray* listData;  //商品列表
//接收从服务器返回数据 Json包
@property (strong,nonatomic) NSMutableData *datas;

@property (strong, nonatomic) NSString *itemid;           //传入参数id

@property (nonatomic,strong) NSString *itemname;  //商品名称
@property (nonatomic,strong) NSString *itemdetail;  //商品详情数据
@property (nonatomic,strong) NSString *itemprice;  //商品单价
@property (nonatomic,strong) NSString *itemAmount;  //商品数量
@property (nonatomic,strong) NSString *itemTotal;  //商品总价[主要]
@property (nonatomic,strong) NSString *itemPay;  //商品应付金额[主要]
@property (nonatomic,strong) NSString *PayAction;  //是否是继续支付
@property (nonatomic,strong) NSString *Payid;  //继续支付的id
@property (nonatomic,strong) NSString *OrderID;  //订单编号
@property (nonatomic,strong) NSString *OrderSn;  //订单编号
@property (nonatomic,strong) NSString *UserID;   //用户编号

//订单详情[包含4部分]
@property (strong,nonatomic) NSDictionary *dict_orderdetails;  //传入


@property (strong, nonatomic) NSString *userid;           //传入参数id
@property (strong, nonatomic) NSString *username;           //参数name
@property (nonatomic) double usermoney;         //余额
@property (nonatomic) double userpoints;        //积分

@property (nonatomic) double pointsinorder;        //本单可使用的积分

@property (nonatomic) double usedmoney;         //已使用的余额
@property (nonatomic) double usedpoints;        //已使用的积分
@property (nonatomic) double usedbonus;         //已使用的红包

@property (strong,nonatomic) NSString *usedbonusid;         //已使用的红包ID

@property (nonatomic) double totalpay;        //总计需要支付的金额

@property (nonatomic) double usedmoneylimit;         //最大可用的余额
@property (nonatomic) double usedpointslimit;        //最大可用的积分
@property (nonatomic) double usedbonuslimit;         //最大可用的红包
@property (nonatomic) double totalpaylimit;          //最大可付款额

@property (nonatomic) int selectedbonus;         //选中的红包

@property (strong, nonatomic)UIColor *CellBgColor;  //单元格背景色

@property (weak, nonatomic) IBOutlet UILabel *lbUsername;
@property (weak, nonatomic) IBOutlet UILabel *lbUserInfo;

@property (weak, nonatomic) IBOutlet UILabel *lbID;

@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UILabel *lbPrice;
@property (weak, nonatomic) IBOutlet UITextView *lbDescription;
@property (weak, nonatomic) IBOutlet UILabel *lbPayContinue;

@property (weak, nonatomic) IBOutlet UILabel *txtMoney;

@property (weak, nonatomic) IBOutlet UILabel *txtPoints;

@property (weak, nonatomic) IBOutlet UIScrollView *detailscrollview;
@property (weak, nonatomic) IBOutlet UIView *subViewPrice;
@property (weak, nonatomic) IBOutlet UIView *subViewPay;

@property (weak, nonatomic) IBOutlet UISwitch *selectPoints;

@property (weak, nonatomic) IBOutlet UISwitch *selectUserMoney;

@property (weak, nonatomic) IBOutlet UISwitch *selectAlipay;

@property (weak, nonatomic) IBOutlet UISwitch *selectWebBanks;


@property (weak, nonatomic) IBOutlet UILabel *lbUserPoints;
@property (weak, nonatomic) IBOutlet UILabel *lbcontusepoints;

@property (weak, nonatomic) IBOutlet UITextField *lbUsedMoney;

@property (weak, nonatomic) IBOutlet UIStepper *btnSkipUserMoney;

@property (weak, nonatomic) IBOutlet UILabel *lbPayMoney;




@property (weak, nonatomic) IBOutlet UILabel *lbResult;

@property (weak, nonatomic) IBOutlet UIButton *btnAlipay;

@property (weak, nonatomic) IBOutlet UIButton *btnPay;

//响应列表中的开关点击事件
- (IBAction) updateSwitchAtIndexPath:(id) sender;

@end
