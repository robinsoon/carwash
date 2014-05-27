//
//  carswashDetailViewController.h
//  tabswashcars
//
//  Created by Robinpad on 14-5-14.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+URLEncoding.h"
#import "UIImageView+WebCache.h"

@interface carswashDetailViewController : UIViewController

@property (strong, nonatomic) NSString *itemid;           //传入参数id
@property (nonatomic,strong) NSString *itemprice;         //商品价格
@property (nonatomic,strong) NSMutableArray* detailData;  //商品详情数据

@property (nonatomic,strong) NSMutableArray* listcommit;  //商品评论


@property (weak, nonatomic) IBOutlet UILabel *lbID;
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UIImageView *imgServiceView;
@property (weak, nonatomic) IBOutlet UIButton *btnBuy;
@property (weak, nonatomic) IBOutlet UIButton *btnAddCart;
@property (weak, nonatomic) IBOutlet UIScrollView *detailscrollview;
@property (weak, nonatomic) IBOutlet UIView *subViewPrice;
@property (weak, nonatomic) IBOutlet UIView *subViewComment;
@property (weak, nonatomic) IBOutlet UILabel *lbDiscount;
@property (weak, nonatomic) IBOutlet UITextField *lbPrice;

@property (weak, nonatomic) IBOutlet UILabel *lbShopPrice;
@property (weak, nonatomic) IBOutlet UILabel *lbClickcount;
@property (weak, nonatomic) IBOutlet UILabel *lbgoodsn;
@property (weak, nonatomic) IBOutlet UILabel *lbStyle;
@property (weak, nonatomic) IBOutlet UILabel *lbDetails;
@property (weak, nonatomic) IBOutlet UILabel *lbPhone;
@property (weak, nonatomic) IBOutlet UILabel *lbAddress;
@property (weak, nonatomic) IBOutlet UILabel *lbNumber;

@property (strong,nonatomic) NSMutableData *Requestdata;      //接收数据
@property (nonatomic) Boolean isConnected;              //连接状态

//重新加载表视图
-(void)reloadDetail:(NSDictionary*)res;

//开始请求Web Service
-(void)startRequestItem;


@end
