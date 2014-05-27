//
//  ViewController.h
//  MQPDemo
//
//  Created by ChaoGanYing on 13-5-6.
//  Copyright (c) 2013年 Alipay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlixLibService.h"

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

@interface AliPayViewController : UIViewController
{
    NSMutableArray *_products;
    SEL _result;
}

@property (nonatomic,assign) SEL result;//这里声明为属性方便在于外部传入。
-(void)paymentResult:(NSString *)result;

@property (strong, nonatomic) NSString *itemid;           //传入参数id

@property (nonatomic,strong) NSString *itemname;  //商品名称
@property (nonatomic,strong) NSString *itemdetail;  //商品详情数据
@property (nonatomic,strong) NSString *itemprice;  //商品价格
@property (nonatomic,strong) NSString *OrderID;  //订单编号
@property (nonatomic,strong) NSString *UserID;   //用户编号


@property (weak, nonatomic) IBOutlet UILabel *lbID;

@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UILabel *lbPrice;
@property (weak, nonatomic) IBOutlet UILabel *lbDescription;

@property (weak, nonatomic) IBOutlet UILabel *lbResult;

@property (weak, nonatomic) IBOutlet UIButton *btnAlipay;

@property (weak, nonatomic) IBOutlet UIButton *btnPay;
@end
